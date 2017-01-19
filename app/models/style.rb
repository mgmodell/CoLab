class Style < ActiveRecord::Base
  has_many :projects, :inverse_of => :style
end
