# frozen_string_literal: true
json.extract! bingo_game, :id, :user_id, :name, :ends_at, :created_at, :updated_at
json.url bingo_game_url(bingo_game, format: :json)
