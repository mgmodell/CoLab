class WorksheetPdf
  include Prawn::View

  def initialize(bingo_board)
    super()
    @bingo_board = bingo_board
    header
    gen_bingo_board
    definitions
  end

  def header
    #This inserts an image in the pdf file and sets the size of the image
    top = cursor

    image "#{Rails.root}/app/assets/images/CoLab.png",
              width: 120, height: 120,
              at: [450, top + 20]
    bounding_box([0, top], :width => 470, :height => 30) do
      text "Player: #{@bingo_board.user.first_name} #{@bingo_board.user.last_name}"
      text "Game Date: #{@bingo_board.bingo_game.end_date}"
    end

  end

  def definitions
    items = [ ]
    @bingo_board.bingo_cells.each do |bc|
      items << [ bc.indeks, bc.candidate.definition ] unless bc.candidate.nil?
    end
    items.sort!{|a,b| a[0] <=> b[0]}

        
    # The cursor for inserting content starts on the top left of the
    # page. Here we move it down a little to create more space between
    # the text and the image inserted above
    y_position = cursor - 10

    # The bounding_box takes the x and y coordinates for positioning its content and some options to style it
    bounding_box([0, y_position], :width => 500, :height => 300) do
      text "<b>Clues:</b>", inline_format: true
      stroke_horizontal_rule
      move_down 5
      items.each do |item|
        text "<b>#{(item[0] + 64).chr}.</b>  #{item[1]}",
            inline_format: true
      end
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
        width: 100,
        height: 100,
        inline_format: true
      }

  end

end

