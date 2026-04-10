# frozen_string_literal: true

require 'test_helper'

class BingoBoardsControllerTest < ActionController::TestCase
  setup do
    @user = User.new
    @user.admin = true

    @bingo_game = BingoGame.new( topic: 'Test Topic', description: 'Test Desc', size: 5 )

    @bingo_board = BingoBoard.new( board_type: :worksheet )
    @bingo_board.bingo_game = @bingo_game
    @bingo_board.bingo_cells = []
    @bingo_board.user = @user
  end

  # --- score_worksheet ---

  test 'score_worksheet saves the performance score' do
    mock = Minitest::Mock.new
    mock.expect( :call, true )

    @bingo_board.stub( :save, mock ) do
      @controller.stub( :authenticate_user!, nil ) do
        @controller.stub( :current_user, @user ) do
          BingoBoard.stub( :find, @bingo_board ) do
            post :score_worksheet, params: { id: 1, performance: 90 }, format: :json
            assert_response :success
            assert_equal 90, @bingo_board.performance
          end
        end
      end
    end
    mock.verify
  end

  test 'score_worksheet returns JSON with bingo_game.result_url key' do
    @bingo_board.stub( :save, true ) do
      @controller.stub( :authenticate_user!, nil ) do
        @controller.stub( :current_user, @user ) do
          BingoBoard.stub( :find, @bingo_board ) do
            post :score_worksheet, params: { id: 1, performance: 75 }, format: :json
            assert_response :success
            json = JSON.parse( response.body )
            assert json.key?( 'bingo_game' ), 'Response should include a bingo_game key'
            assert json['bingo_game'].key?( 'result_url' ), 'bingo_game should include result_url'
          end
        end
      end
    end
  end

  test 'score_worksheet returns nil result_url when no image is attached' do
    @bingo_board.stub( :save, true ) do
      @controller.stub( :authenticate_user!, nil ) do
        @controller.stub( :current_user, @user ) do
          BingoBoard.stub( :find, @bingo_board ) do
            post :score_worksheet, params: { id: 1, performance: 60 }, format: :json
            assert_response :success
            json = JSON.parse( response.body )
            assert_nil json['bingo_game']['result_url'],
                       'result_url should be nil when no image is attached'
          end
        end
      end
    end
  end

  # --- worksheet_results ---

  test 'worksheet_results returns bingo_game and practice_answers' do
    @controller.stub( :authenticate_user!, nil ) do
      @controller.stub( :current_user, @user ) do
        BingoBoard.stub( :find, @bingo_board ) do
          get :worksheet_results, params: { id: 1 }, format: :json
          assert_response :success
          json = JSON.parse( response.body )
          assert json.key?( 'bingo_game' ), 'Response should include bingo_game'
          assert json.key?( 'practice_answers' ), 'Response should include practice_answers'
          assert_equal 'Test Topic', json['bingo_game']['topic']
        end
      end
    end
  end

  test 'worksheet_results redirects non-worksheet boards to root' do
    @bingo_board.board_type = :playable

    @controller.stub( :authenticate_user!, nil ) do
      @controller.stub( :current_user, @user ) do
        BingoBoard.stub( :find, @bingo_board ) do
          get :worksheet_results, params: { id: 1 }, format: :json
          assert_redirected_to root_path
        end
      end
    end
  end
end
