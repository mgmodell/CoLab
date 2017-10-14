class BingoCell < ActiveRecord::Base
  belongs_to :BingoBoard
  belongs_to :Concept
end
