# frozen_string_literal: true

require 'chronic'
require 'faker'

Given( 'there is a student with a bingo worksheet board' ) do
  # Pick one of the enrolled users as our tracked student
  @student = @course.rosters.enrolled.first.user
  @worksheet_board = BingoBoard.worksheet.find_by( user: @student, bingo_game: @bingo )
  if @worksheet_board.nil?
    @worksheet_board = BingoBoard.create!(
      board_type: :worksheet,
      user: @student,
      bingo_game: @bingo
    )
  end
end

Given( 'the user is a student with the scored worksheet' ) do
  @user = @student
end

When( 'the instructor visits the worksheet score page' ) do
  visit Capybara.app_host + '/home/bingo/score_bingo_worksheet/' +  @worksheet_board.id.to_s

  wait_for_render
end

Then( 'the instructor sees the worksheet scoring form' ) do
  page.should have_css( "input[id='score']" )
end

When( 'the instructor sets the score to {int}' ) do | score |
  fill_in 'score', with: score.to_s
end

When( 'the instructor uploads a result image' ) do
  @image_path = Rails.root.join( 'test', 'fixtures', 'files', 'test_image.png' )
  # The file input is hidden; attach_file with make_visible: true handles this
  page.attach_file( 'result_photo', @image_path.to_s, make_visible: true )
end

When( 'the instructor submits the score' ) do
  click_button I18n.t( 'bingo_games.submit_scores' )
  wait_for_render
end

Then( 'the scored worksheet has an image stored in Active Storage' ) do
  @worksheet_board.reload
  @worksheet_board.result_img.attached?.should be true
end

Then( 'the instructor sees the result image on the score page' ) do
  wait_for_render
  page.should have_css( "img[src*='/rails/active_storage']",
                        wait: 10 )
end

Given( 'the worksheet board has a scored image attached' ) do
  @worksheet_board ||= BingoBoard.worksheet.find_by( bingo_game: @bingo )
  @worksheet_board ||= BingoBoard.create!(
    board_type: :worksheet,
    user: @course.rosters.enrolled.first.user,
    bingo_game: @bingo
  )
  image_path = Rails.root.join( 'test', 'fixtures', 'files', 'test_image.png' )
  @worksheet_board.result_img.attach(
    io: File.open( image_path ),
    filename: 'test_image.png',
    content_type: 'image/png'
  )
  @worksheet_board.performance = 90
  @worksheet_board.save!
  @student = @worksheet_board.user
end

Then( 'the user sees the scored result image' ) do
  wait_for_render
  page.should have_css( 'img', wait: 10 )
end
