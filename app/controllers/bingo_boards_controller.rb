# frozen_string_literal: true

class BingoBoardsController < ApplicationController
  before_action :set_bingo_board,
                except: %i[index update board_for_game board_for_game_demo
                           update_demo demo_worksheet_for_game worksheet_for_game ]
  before_action :check_editor, only: %i[worksheet_results score_worksheet]
  skip_before_action :authenticate_user!,
                     only: %i[board_for_game_demo update_demo
                              demo_worksheet_for_game]
  before_action :demo_user,
                only: %i[board_for_game_demo update_demo demo_worksheet_for_game]

  include Demoable
  # Constants Declaration
  ITEM_COUNT = 10

  def show
    respond_to do | format |
      format.json { render json: @bingo_board }
    end
  end

  def board_for_game_demo
    # params[:bingo_game_id]
    demo_project = Project.new(
      id: -1,
      name: ( t :demo_project ),
      course_id: -1
    )
    bingo_game = get_demo_bingo_game
    bingo_game.project = demo_project
    bingo_game.topic = t 'candidate_lists.demo_bingo_topic'
    bingo_game.description = t 'candidate_lists.demo_bingo_description'
    bingo_game.end_date = 1.day.from_now.end_of_day

    # let the monkey-patching begin!
    def bingo_game.playable?
      true
    end

    def bingo_game.practicable?
      true
    end

    bingo_board = BingoBoard.new(
      bingo_game:,
      user: current_user,
      iteration: 0,
      performance: 88
    )
    if 'pdf' == params[:format]
      bingo_board.bingo_cells = []
      # reconstitue saved items
      cells_array = JSON.parse( session[:demo_cells] )
      cells_array.each do | c |
        bingo_board.bingo_cells <<
          BingoCell.new(
            row: c['row'],
            column: c['column'],
            concept: Concept.new( name: c['concept']['name'] )
          )
      end
    end
    board_for_game_helper bingo_board:, bingo_game:
  end

  def board_for_game
    # params[:bingo_game_id]
    bingo_game = BingoGame.find( params[:bingo_game_id] )
    bingo_board = bingo_game.bingo_boards.playable
                            .includes( :bingo_game, bingo_cells: :concept )
                            .find_by( user_id: current_user.id )
    worksheet = bingo_game.bingo_boards.worksheet
                          .find_by( user_id: current_user.id )
    board_for_game_helper bingo_board:,
                          worksheet:,
                          bingo_game:,
                          acceptable_count: bingo_game.candidates
                                                      .where( candidate_feedback_id: 1 )
                                                      .group( :concept_id ).length
  end

  def board_for_game_helper( bingo_game:, bingo_board: nil,
                             acceptable_count: 42,
                             worksheet: nil )
    # TODO: Maybe this can be simplified?
    if bingo_board.nil?
      bingo_board = BingoBoard.new
      bingo_board.bingo_game = bingo_game
      bingo_board.user = current_user
      bingo_board.iteration = 0
    end

    cells = bingo_board.bingo_cells
    #                   .order(row: :asc, column: :asc).to_a
    size = bingo_board.bingo_game.size
    cells.sort { | a, b | ( ( size * a.row ) + a.column ) <=> ( ( size * b.row ) + b.column ) }
    # Let's init those cells
    mid = ( size / 2.0 ).round
    size.times do | row |
      size.times do | column |
        i = size * row + column
        cells[i]
        next unless cells[i].nil?

        cell = bingo_board.bingo_cells.build
        cell.selected = ( row == mid ) && column == mid
        cell.row = row
        cell.column = column
      end
    end

    url = bingo_board.id.nil? ? root_url : ws_results_url( bingo_board.id )

    respond_to do | format |
      format.json do
        resp = bingo_board.as_json(
          only: %i[id size topic description bingo_game_id performance],
          include: [:bingo_game, { bingo_cells: {
            only: %i[id bingo_board_id row column
                     selected concept_id],
            include:
                 [concept: { only: %i[id name] }]
          } }]
        )
        resp[:acceptable] = acceptable_count
        resp[:playable] = bingo_game.playable?
        resp[:practicable] = bingo_game.practicable?
        unless worksheet.nil?
          resp[:worksheet] = {
            performance: worksheet.performance,
            result_img: worksheet.result_img.attached? ? url_for( worksheet.result_img ) : nil
          }
        end
        resp[:result_img] = url_for( bingo_board.result_img ) if bingo_board.result_img.attached?
        render json: resp
      end
      format.pdf do
        pdf = WorksheetPdf.new( bingo_board, url: )
        send_data pdf.render, filename: 'bingo_game.pdf', type: 'application/pdf'
      end
    end
  end

  def demo_worksheet_for_game
    bingo_game = get_demo_bingo_game
    concepts = get_demo_game_concepts

    wksheet = BingoBoard.new(
      id: -42,
      iteration: 0,
      user_id: current_user.id,
      user: current_user,
      bingo_cells: [],
      bingo_game:,
      board_type: :worksheet
    )

    index = 0
    star = ['*', 'free space']
    0.upto( bingo_game.size - 1 ) do | row |
      0.upto( bingo_game.size - 1 ) do | column |
        c = star
        is_answer = false
        unless 2 == row && 2 == column
          c = concepts.delete( concepts.sample )
          is_answer = ( row == column ) ||
                      ( 5 == ( row + column ) ) ||
                      ( 1 == ( row + column ) )
        end
        wksheet.bingo_cells << BingoCell.new(
          row:,
          column:,
          concept: Concept.new( name: c[0] )
        )
        next unless is_answer

        cell = wksheet.bingo_cells.last
        cell.candidate = Candidate.new( definition: c[1] )
        cell.indeks = index += 1
      end
    end

    respond_to do | format |
      format.pdf do
        pdf = WorksheetPdf.new( wksheet,
                                url: root_url )
        send_data pdf.render, filename: 'demo_bingo_practice.pdf', type: 'application/pdf'
      end
    end
  end

  def worksheet_results
    if @bingo_board.worksheet?
      bingo_game = @bingo_board.bingo_game
      @practice_answers = Array.new bingo_game.size
      bingo_game.size.times do | index |
        @practice_answers[index] = Array.new bingo_game.size
      end
      @bingo_board.bingo_cells.each do | bc |
        @practice_answers[bc.row][bc.column] = bc.indeks_as_letter if bc.candidate.present?
      end
      respond_to do | format |
        format.json do
          render json: {
            bingo_game: {
              topic: bingo_game.topic,
              description: bingo_game.description,
              result_url: @bingo_board.result_img.present? ? url_for( @bingo_board.result_img ) : nil
            },
            practice_answers: @practice_answers.as_json
          }
        end
      end
    else
      redirect_to root_path
    end
  end

  def worksheet_for_game
    bingo_game_id = params[:bingo_game_id]
    if '-42' == bingo_game_id
      demo_worksheet_for_game

    else
      bingo_game = BingoGame.find( params[:bingo_game_id] )
      wksheet = bingo_game.bingo_boards.worksheet
                          .includes( :bingo_game, bingo_cells: %i[concept candidate] )
                          .find_by( user_id: current_user.id )

      if wksheet.blank?
        candidates = bingo_game.candidates.acceptable.to_a
        # Assuming 10 items
        items = {}

        while items.length < ITEM_COUNT && !candidates.empty?
          candidate = candidates.sample
          items[candidate.concept] = candidate
          candidates.delete( candidate )
        end

        wksheet = BingoBoard.new(
          iteration: 0,
          user_id: current_user.id,
          user: current_user,
          bingo_game:,
          board_type: :worksheet
        )

        # Distribute clues and board elements
        concepts = bingo_game.concepts.to_a
        if ITEM_COUNT == items.length && concepts.size > 25
          cells = items.values
          while cells.length < 24
            c = concepts.delete( concepts.sample )
            cells << c if items[c].nil?
          end
          # Initialise the indexes
          indices = ( 1..10 ).to_a
          star = Concept.find 0
          0.upto( bingo_game.size - 1 ) do | row |
            0.upto( bingo_game.size - 1 ) do | column |
              c = star
              c = cells.delete( cells.sample ) unless 2 == row && 2 == column
              wksheet.bingo_cells.build(
                row:,
                column:,
                concept: c.instance_of?( Concept ) ? c : c.concept,
                candidate: c.instance_of?( Concept ) ? nil : c,
                indeks: c.instance_of?( Concept ) ? nil : indices.delete( indices.sample )
              )
            end
          end
        end
        wksheet.save
        logger.debug wksheet.errors.full_messages unless wksheet.errors.empty?
      end

      respond_to do | format |
        format.pdf do
          url = "#{root_url}home/bingo/score_bingo_worksheet/#{wksheet.id}"
          # TODO: there's got to be a better way to do this.
          pdf = WorksheetPdf.new( wksheet, url: )
          send_data pdf.render, filename: 'bingo_practice.pdf', type: 'application/pdf'
        end
      end
    end
  end

  # GET /admin/bingo_board
  def index
    # Narrow down to those available to the user
    @bingo_boards = BingoBoard.where user: current_user
    respond_to do | format |
      format.json do
        render json: @bingo_boards.collect do | board |
          { id: board.id, name: board.bingo_game.topic }
        end
      end
    end
  end

  def update_demo
    # params[:bingo_game_id]
    @board = BingoBoard.new(
      id: -42,
      iteration: 0,
      user_id: current_user.id,
      user: current_user,
      board_type: :playable
    )
    # @board.assign_attributes(bingo_board_params)

    cells = []
    params[:bingo_board][:bingo_cells_attributes].each do | bc_hash |
      bc = BingoCell.new(
        row: bc_hash[:row],
        column: bc_hash[:column],
        concept_id: bc_hash[:concept][:id],
        concept: Concept.new(
          name: bc_hash[:concept][:name]
        )
      )
      cells << bc
    end
    session[:demo_cells] = cells.to_json( only: %i[row column], include: [concept: { only: :name }] )

    update_responder
  end

  def update
    bingo_game_id = params[:bingo_game_id]
    @board = BingoBoard.playable.find_by(
      user_id: current_user.id,
      bingo_game_id:
    )
    if @board.nil?
      @board = BingoBoard.new(
        user_id: current_user.id,
        user: current_user,
        bingo_game_id:
      )
    end

    iteration = @board.iteration
    # @board.user_id = current_user.id
    # @board.bingo_game_id = bingo_game_id
    @board.iteration += iteration

    cells = []
    params[:bingo_board][:bingo_cells_attributes].each do | bc_hash |
      bc = BingoCell.find_by( id: bc_hash[:id] )
      if bc.nil?
        bc = @board.bingo_cells.build(
          row: bc_hash[:row],
          column: bc_hash[:column]
        )
      end
      bc.concept_id = bc_hash[:concept_id]
      bc.save
      cells << bc
    end
    @board.bingo_cells = cells

    bingo_game = @board.bingo_game
    if @board.save
      @board = BingoBoard
               .includes( :bingo_game, bingo_cells: :concept )
               .find( @board.id )

      board_for_game_helper bingo_board: @board,
                            bingo_game:,
                            acceptable_count: bingo_game.candidates
                                                        .where( candidate_feedback_id: 1 )
                                                        .group( :concept_id ).length
    else
      logger.debug @board.errors.full_messages

      respond_to do | format |
        format.json do
          render json: { message: @board.errors.full_messages }
        end
      end

    end
  end

  def score_worksheet
    require 'image_processing/vips'
    # Rails.logger.debug "params: #{params}"

    @bingo_board.performance = params[:performance]

    # image processing
    unless params[:result_img].nil?
      proc_image = ImageProcessing::Vips
                   .source( params[:result_img].tempfile.path )
                   .resize_to_limit!( 800, 800 )

      @bingo_board.result_img.attach( io: File.open( proc_image.path ),
                                      filename: File.basename( proc_image.path ) )
    end

    resp_hash = {
      msg: if @bingo_board.errors.empty?
             t( 'scored_success' )
           else
             @bingo_board.errors.full_message
           end,
      result_url: url_for( @bingo_board.result_img )
    }
    respond_to do | format |
      format.json do
        render json: resp_hash
      end
    end
  end

  private

  def update_responder
    respond_to do | format |
      format.json do
        render json: @board.to_json(
          only: %i[id size topic bingo_game_id], include:
               [:bingo_game, { bingo_cells:
               { only: [:id, :bingo_board_id,
                        :row, :column, :selected, 'concept_id'],
                 include:
                 [concept: { only: %i[id name] }] } }]
        )
      end
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_bingo_board
    id = params[:id].to_i
    if id <= 0
      redirect_to root_path
    else
      @bingo_board = BingoBoard.find( id )
    end
  end

  def check_editor
    unless current_user.is_admin? ||
           @bingo_board.bingo_game.course.rosters.instructor.where( user: current_user ).present?
      redirect_to root_path
    end
  end
end
