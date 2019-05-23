# frozen_string_literal: true

require 'forgery'

class BingoGamesController < ApplicationController
  layout 'admin', except: %i[review_candidates update_review_candidates
                             review_candidates_demo game_results ]
  skip_before_action :authenticate_user!,
                     only: %i[review_candidates_demo
                              demo_update_review_candidates ]
  before_action :demo_user, only: %i[ review_candidates_demo
                                      demo_update_review_candidates ]

  before_action :set_bingo_game, only: %i[show update
                                          destroy review_candidates
                                          update_review_candidates ]

  before_action :check_editor, except: %i[next diagnose react
                                          update_review_candidates
                                          review_candidates_demo
                                          demo_update_review_candidates
                                          show index get_concepts]

  before_action :check_viewer, only: %i[show index]

  include Demoable

  def show
    @title = t '.title'
    respond_to do |format|
      format.html { render :show }
      format.json do
        resp = @bingo_game.as_json(only:
          %i[ id topic description source group_option individual_count
              start_date end_date active lead_time group_discount
              reviewed project_id ])
        resp[:topic] = @bingo_game.get_topic(@current_user.anonymize?)
        resp[:reviewed] = @bingo_game.reviewed?
        resp[:projects] = @bingo_game.course.projects
                                     .collect do |p|
          {
            id: p.id,
            name: p.get_name(@current_user.anonymize?)
          }
        end .as_json
        render json: resp
      end
    end
  end

  def game_results
    bingo_game = BingoGame.includes(
      [course: { rosters: { user: :emails } }, candidate_lists: [:user,
                                                                 { candidates: %i[concept candidate_feedback] }, group: :users],
       bingo_boards: { bingo_cells: :candidate }]
    ).find(params[:id])
    anon = @current_user.anonymize?
    resp = {}
    bingo_game.course.rosters.each do |r|
      next unless r.enrolled_student? || r.invited_student?

      resp[ r.user.id ] = {
        student: r.user.informal_name(anon),
        last_name: anon ? r.user.anon_last_name : r.user.last_name,
        email: anon ? 'phony@mailinator.com' : r.user.email,
        group: 'N/A',
        concepts_expected: bingo_game.individual_count,
        concepts_entered: 0,
        concepts_credited: 0,
        term_problems: 0,
        performance: 0,
        candidates: [],
        practice_answers: []
      }
    end
    # Get the worksheets
    bingo_game.bingo_boards.each do |bb|
      next unless bb.worksheet?

      practice_answers = Array.new bingo_game.size
      bingo_game.size.times do |index|
        practice_answers[index] = Array.new bingo_game.size
      end
      bb.bingo_cells.each do |bc|
        if bc.candidate.present?
          practice_answers[bc.row][bc.column] =
            bc.indeks_as_letter
        end
      end
      resp[bb.user.id][:practice_answers] = practice_answers
    end

    bingo_game.candidate_lists.each do |cl|
      if !cl.is_group
        user_id = cl.user_id
        if resp[user_id].present?
          resp[user_id][:concepts_expected] = cl.candidates.size
          resp[user_id][:concepts_entered] = cl.candidates
                                               .reject { |c| (c.definition.empty? || c.term.empty?) }.count
          resp[user_id][:concepts_credited] = cl.candidates
                                                .reject do |c|
            c.candidate_feedback.present? &&
              c.candidate_feedback.name.start_with?('Term')
          end .count
          resp[user_id][:term_problems] = cl.candidates
                                            .reject do |c|
            c.candidate_feedback.present? &&
              !c.candidate_feedback.name.start_with?('Term')
          end .count
          resp[user_id][:performance] = cl.performance
          candidates = []
          cl.candidates.completed.each do |c|
            candidates << {
              term: c.term,
              definition: c.definition,
              concept: c.concept.present? ? c.concept.name : nil,
              feedback: c.candidate_feedback.name,
              feedback_id: c.candidate_feedback_id
            }
          end
          resp[user_id][:candidates] = candidates
        end
      elsif cl.is_group && cl.group.present?
        concepts_expected = cl.candidates.size
        concepts_entered = cl.candidates
                             .reject { |c| c.definition.empty? || c.term.empty? }.count
        concepts_credited = cl.candidates
                              .reject do |c|
          c.candidate_feedback.present? &&
            c.candidate_feedback.name.start_with?('Term')
        end .count
        term_problems = cl.candidates
                          .reject do |c|
          c.candidate_feedback.present? &&
            !c.candidate_feedback.name.start_with?('Term')
        end .count
        performance = cl.performance
        candidates = []
        cl.candidates.completed.each do |c|
          candidates << {
            term: c.term,
            definition: c.definition,
            concept: c.concept.present? ? c.concept.name : nil,
            feedback: c.candidate_feedback.name,
            feedback_id: c.candidate_feedback_id
          }
        end
        cl.group.users.each do |u|
          resp[u.id][:group] = cl.group.get_name(anon)
          resp[u.id][:concepts_expected] = concepts_expected
          resp[u.id][:concepts_credited] = concepts_credited
          resp[u.id][:concepts_entered] = concepts_entered
          resp[u.id][:term_problems] = term_problems
          resp[u.id][:performance] = performance
          resp[u.id][:candidates] = candidates
        end

      end
    end
    resp_array = []
    resp.keys.each do |key|
      resp[key][:id] = key
      resp_array << resp[key]
    end
    render json: resp_array
  end

  def index
    @title = t '.title'
    @bingo_games = []
    if @current_user.is_admin?
      @bingo_games = BingoGame.includes(:course).all
    else
      rosters = @current_user.rosters.includes(course: :bingo_games).instructor
      rosters.each do |roster|
        @bingo_games.concat roster.course.bingo_games.to_a
      end
    end
  end

  def new
    @title = t '.title'
    @bingo_game = Course.find(params[:course_id]).bingo_games.new
    @bingo_game.start_date = @bingo_game.course.start_date
    @bingo_game.end_date = @bingo_game.course.end_date
  end

  def create
    @title = t 'bingo_games.new.title'
    @bingo_game = BingoGame.new(bingo_game_params)
    if @bingo_game.save
      redirect_to @bingo_game, notice: t('bingo_games.create_success')
    else
      logger.debug @bingo_game.errors.full_messages unless @bingo_game.errors.empty?
      render :new
    end
  end

  def update
    @title = t '.title'
    @bingo_game.update(bingo_game_params)

    respond_to do |format|
      format.json do
        if @bingo_game.errors.empty?
          render json: {
            notice: 'Game saved successfully!',
            messages: {}
          }
        else
          render json: {
            notice: 'Unable to save',
            messages: @bingo_game.errors
          }
        end
      end
    end
  end

  def review_candidates_demo
    @title = t('demo_title', orig:
      t('bingo_games.review_candidates.title'))
    @bingo_game = get_demo_bingo_game

    groups =
      [Group.new(
        id: -1,
        name: "#{Forgery::Basic.frequency} #{Forgery::Basic.color}",
        anon_name: "#{Forgery::Basic.frequency} #{Forgery::Basic.color}",
        project_id: -1
      ),
       Group.new(
         id: -2,
         name: "#{Forgery::Basic.frequency} #{Forgery::Basic.color}",
         anon_name: "#{Forgery::Basic.frequency} #{Forgery::Basic.color}",
         project_id: -1
       )]

    cl_map = {}
    candidate_lists = []
    # working as a group
    cl = CandidateList.new ()
    cl.id = -1
    cl.is_group = true
    cl.archived = false
    cl.contributor_count = 1
    cl.group_id = -1
    cl.group = groups[0]
    cl.bingo_game_id = @bingo_game.id
    cl.bingo_game = @bingo_game
    candidate_lists << cl
    @bingo_game.candidate_lists << cl

    0.downto(-3) do |index|
      u = User.new ()
      u.id = index
      u.first_name = Forgery::Name.first_name
      u.anon_first_name = Forgery::Name.first_name
      u.last_name = Forgery::Name.last_name
      u.anon_last_name = Forgery::Name.last_name
      u.email = 'test@mailinator.com'

      groups[0].users << u
      cl_map[u] = cl
    end
    # Working on their own
    -4.downto(-7) do |index|
      u = User.new
      u.id = index
      u.first_name = Forgery::Name.first_name
      u.anon_first_name = Forgery::Name.first_name
      u.last_name = Forgery::Name.last_name
      u.anon_last_name = Forgery::Name.last_name
      u.email = 'test@mailinator.com'

      cl = CandidateList.new
      cl.id = index
      cl.archived = false
      cl.contributor_count = 1
      cl.is_group = false
      cl.user_id = u.id
      cl.user = u
      cl.bingo_game_id = @bingo_game.id
      cl.bingo_game = @bingo_game
      candidate_lists << cl
      @bingo_game.candidate_lists << cl
      groups[1].users << u
      cl_map[u] = cl
    end

    demo_concepts = get_demo_game_concepts
    demo_concepts.rotate!(Random.rand(demo_concepts.count))
    users = cl_map.keys

    candidates = []
    0.downto(-66) do |index|
      c = demo_concepts.rotate![0]
      acceptable = Random.rand < 0.5
      users.rotate!
      u = users[0]
      candidate = Candidate.new(
        id: index,
        term: c[0],
        definition: acceptable ? c[1] :
          demo_concepts[Random.rand(demo_concepts.count)][1],
        user: u,
        user_id: u.id
      )
      cl_map[u].candidates << candidate
      candidates << candidate
    end

    respond_to do |format|
      format.json do
        review_helper(
          bingo_game: @bingo_game,
          users: users,
          groups: groups,
          candidate_lists: candidate_lists,
          candidates: candidates
        )
      end
      format.html { render :review_candidates }
    end
  end

  def review_candidates
    @title = t '.title'
    respond_to do |format|
      format.json do
        review_helper(
          bingo_game: @bingo_game,
          users: @bingo_game.users.includes( :emails ),
          groups: @bingo_game.groups,
          candidate_lists: @bingo_game.candidate_lists,
          candidates: @bingo_game.candidates.completed
        )
      end
      format.html { render :review_candidates }
    end
  end

  def review_helper(bingo_game:, users:, groups:,
                    candidate_lists:, candidates:)
    render json: {
      bingo_game: bingo_game.as_json(only:
        %i[id topic description status close_date]),
      users: users.as_json(only:
        %i[id first_name last_name], methods: :email),
      feedback_opts: CandidateFeedback.all.as_json(only:
        %i[id name_en definition_en credit]),
      groups: groups.as_json(only:
        %i[id name]),
      candidate_lists: candidate_lists.as_json(only:
        %i[id is_group group_id]),
      candidates: candidates.as_json(
        include: { concept: { only: :name } },
        only: %i[id term definition concept_id
                 candidate_feedback_id candidate_list_id
                 filtered_consistent user_id]
      )
    }
  end

  def demo_update_review_candidates
    response = {
      notice: 'demo done!',
      reviewed: params[:reviewed]
    }
    respond_to do |format|
      format.json { render json: response }
    end
  end

  def update_review_candidates
    bingo_id = params[:id].to_i
    response = {}
    if bingo_id < 1
      response[:notice] = 'Error!'
      response[:reviewed] = params[:reviewed]

    else
      @bingo_game = BingoGame.find(bingo_id)
      # Security check to support demos
      redirect_to root_path unless @current_user.present? &&
                                   @bingo_game.course.instructors.include?(@current_user)

      candidates = params[:candidates]
      entered_concepts = []
      candidates.each do |candidate|
        next unless candidate[:concept].present? && candidate[:concept][:name].present?

        concept_name = candidate[:concept][:name]
        concept_name = concept_name.split.map(&:capitalize).*' '
        entered_concepts << concept_name
      end

      concept_map = {}
      Concept.where(name: entered_concepts).each do |c|
        concept_map[c.name] = c
      end

      feedback_map = {}
      CandidateFeedback.all.each do |cf|
        feedback_map[cf.id] = cf
      end

      candidate_map = {}
      candidates.each do |c|
        candidate_map[c[:id]] = c
      end

      # Process the data
      existing_concepts = {}

      @bingo_game.candidates.completed
                 .includes(:candidate_feedback,
                           :concept,
                           :user,
                           candidate_list: :bingo_game  )
                 .find_all do |candidate|
        entered_candidate = candidate_map[candidate.id]

        next if entered_candidate.nil? || entered_candidate[:candidate_feedback_id].nil?

        candidate.candidate_feedback =
          feedback_map[entered_candidate[:candidate_feedback_id]]

        feedback_name = candidate.candidate_feedback.name_en
        if (!feedback_name.start_with? 'Term:') &&
           entered_candidate[:concept][:name].present?
          concept_name = entered_candidate[:concept][:name]
          concept_name = Concept.standardize_name name: concept_name

          concept = concept_map[concept_name]
          if concept.nil?
            concept = Concept.create(name: concept_name)
            concept_map[concept_name] = concept
          end
          candidate.concept = concept
        else
          candidate.concept = nil
        end
        candidate.save
        logger.debug candidate.errors.full_messages unless candidate.errors.empty?
      end

      # Send notifications to students
      @bingo_game.reviewed = params['reviewed']
      if @bingo_game.reviewed && !@bingo_game.students_notified
        @bingo_game.course.enrolled_students.find_all do |student|
          AdministrativeMailer.notify_availability(student,
                                                   "#{@bingo_game.topic} terms list").deliver_later
        end
        @bingo_game.students_notified = true
      end
      @bingo_game.save
      logger.debug @bingo_game.errors.full_messages unless @bingo_game.errors.empty?

      if @bingo_game.errors.empty?
        response[:notice] = (t 'bingo_games.review_success')
        response[:reviewed] = @bingo_game.reviewed
      elsif !@bingo_game.errors.empty?
        response[:notice] = (t 'bingo_games.review_problems')
        response[:reviewed] = false
      end
    end
    respond_to do |format|
      format.json { render json: response }
    end
  end

  def destroy
    @course = @bingo_game.course
    @bingo_game.destroy
    redirect_to @course, notice: (t 'bingo_games.destroy_success')
  end

  def activate
    bingo_game = BingoGame.find(params[:bingo_game_id])
    if @current_user.is_admin? ||
       bingo_game.course.get_roster_for_user(@current_user).role.code == 'inst'
      bingo_game.active = true
      bingo_game.save
    end
    @bingo_game = bingo_game
    @title = t 'bingo_games.show.title'
    render :show, notice: (t 'bingo_games.activate_success')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bingo_game
    bg_test = BingoGame.joins(:course).includes({ candidate_lists: {candidates: :concept }, course: :projects }).find(params[:id])
    if @current_user.is_admin?
      @bingo_game = bg_test
    else
      @course = bg_test.course
      if bg_test.course.rosters.instructor.where(user: @current_user).nil?
        redirect_to @course if @bingo_game.nil?
      else
        @bingo_game = bg_test
      end
    end
  end

  def check_viewer
    redirect_to root_path unless @current_user.is_admin? ||
                                 @current_user.is_instructor? ||
                                 @current_user.is_researcher?
  end

  def check_editor
    redirect_to root_path unless @current_user.is_admin? || @current_user.is_instructor?
  end

  def bingo_game_params
    params.require(:bingo_game).permit(:course_id, :topic, :description, :link, :source,
                                       :active, :group_option, :individual_count,
                                       :group_discount, :lead_time, :project_id,
                                       :start_date, :end_date)
  end
end
