# frozen_string_literal: true

class WorksheetPdf
  include Prawn::View

  def initialize( bingo_board, url: )
    super()
    font_families.update( 'OpenSans' => {
                           normal: Rails.root.join( 'app/assets/fonts/OpenSans-Regular.ttf' ),
                           italic: Rails.root.join( 'app/assets/fonts/OpenSans-Italic.ttf' ),
                           bold: Rails.root.join( 'app/assets/fonts/OpenSans-Bold.ttf' ),
                           bold_italic: Rails.root.join( 'app/assets/fonts/OpenSans-BoldItalic.ttf' )
                         } )

    font 'OpenSans'
    @bingo_board = bingo_board
    @url = url
    header
    gen_bingo_board
    render_clues if @bingo_board.worksheet?
  end

  def header
    # This inserts an image in the pdf file and sets the size of the image
    top = cursor

    image Rails.root.join( 'app/assets/images/CoLab.png' ).to_s,
          width: 120, height: 120,
          at: [450, top + 20]
    if @bingo_board.worksheet?
      qrcode = RQRCode::QRCode.new( @url )
      move_down 44
      render_qr_code( qrcode )
      # pos: [0 - 3, top - 43])
    end
    bounding_box( [0, top], width: 210 ) do
      text "Player: #{@bingo_board.user_first_name} #{@bingo_board.user_last_name}"
      text "Game Date: #{@bingo_board.bingo_game_end_date.strftime( '%b %e, %Y' )}"
    end
    bounding_box( [220, top], width: 240 ) do
      text "Class: #{@bingo_board.bingo_game_course.name}"
      text "Number: #{@bingo_board.bingo_game_course.number}"
    end
    move_down 5
    text "<b>Topic: #{@bingo_board.bingo_game_topic}</b>",
         align: :center, inline_format: true
  end

  def render_clues
    items = []
    @bingo_board.bingo_cells.each do | bc |
      items << [bc.indeks_as_letter, bc.candidate.definition, bc.concept] unless bc.candidate.nil?
    end
    items.sort_by! { | a | a[0] }

    move_down 10
    # The bounding_box takes the x and y coordinates for positioning its content and some options to style it
    text 'Write the letter of the clue below in the box of the ' \
         'matching concept above.'
    text '<b>Clues:</b>', inline_format: true
    stroke_horizontal_rule
    move_down 5
    items.each do | item |
      Candidate.filter.filter( item[2].name.remove( '(', ')' ).split( /\W+/ ) ).each do | w |
        item[1].gsub!( /\b#{w}/, ( '*' * w.length ) )
      end
      text "<b>#{item[0]}.</b>  #{item[1]}",
           inline_format: true
    end
  end

  def gen_bingo_board
    size = @bingo_board.bingo_game_size
    data = Array.new( size ) { Array.new( size ) }
    @bingo_board.bingo_cells.each do | bc |
      data[bc.row][bc.column] = if '*' == bc.concept.name
                                  '<color rgb=\'FF00FF\'><font size=\'48\'>*</font></color>'
                                else
                                  bc.concept.name
                                end
    end

    table data, position: :center,
                cell_style: {
                  valign: :center,
                  align: :center,
                  width: 90,
                  height: 90,
                  inline_format: true
                }
  end
end
