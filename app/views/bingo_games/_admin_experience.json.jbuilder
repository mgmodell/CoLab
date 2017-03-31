# frozen_string_literal: true
json.extract! bingo_game, :id, :user_id, :name, :ends_at, :created_at, :updated_at
json.url experience_url(bingo_game, format: :json)
