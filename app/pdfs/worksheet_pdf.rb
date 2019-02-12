class WorksheetPdf
  include Prawn::View

  def initialize(bingo_board)
    super()
    @bingo_board = bingo_board
    header
    gen_bingo_board
    render_clues if @bingo_board.worksheet?
  end

  def header
    #This inserts an image in the pdf file and sets the size of the image
    top = cursor

    image "#{Rails.root}/app/assets/images/CoLab.png",
              width: 120, height: 120,
              at: [450, top + 20]
    bounding_box([0, top], :width => 210) do
      text "Player: #{@bingo_board.user.first_name} #{@bingo_board.user.last_name}"
      text "Game Date: #{@bingo_board.bingo_game.end_date.strftime( "%b %e, %Y" )}"
    end
    bounding_box([220, top], :width => 240) do
      text "Class: #{@bingo_board.bingo_game.course.name}"
      text "Number: #{@bingo_board.bingo_game.course.number}"
    end
    move_down 5
    text "<b>Topic: #{@bingo_board.bingo_game.topic}</b>",
      align: :center, inline_format: true

  end

  def render_clues
    items = [ ]
    @bingo_board.bingo_cells.each do |bc|
      items << [ bc.indeks_as_letter, bc.candidate.definition, bc.concept ] unless bc.candidate.nil?
    end
    items.sort!{|a,b| a[0] <=> b[0]}

    move_down 10
    # The bounding_box takes the x and y coordinates for positioning its content and some options to style it
      text "<b>Clues:</b>", inline_format: true
      stroke_horizontal_rule
      move_down 5
      items.each do |item|
        item[2].name.split(/\W+/).each do |w|
          item[1].gsub!( /\b#{w}/, ('*'*w.length) )
        end
        text "<b>#{item[0]}.</b>  #{item[1]}",
            inline_format: true
      end


  end

  def gen_bingo_board
    size = @bingo_board.bingo_game.size
    data = Array.new(size){Array.new(size)}
    @bingo_board.bingo_cells.each do |bc|
      if '*' == bc.concept.name
        data[ bc.row - 1 ][ bc.column - 1 ] = 
          '<color rgb=\'FF00FF\'><font size=\'96\'>*</font></color>'
      else
        data[ bc.row - 1 ][ bc.column - 1 ] = bc.concept.name
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

