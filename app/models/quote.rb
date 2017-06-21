# frozen_string_literal: true
class Quote < ActiveRecord::Base
  translates :text

  @@reloaded_at = DateTime.current
  @@quote_count = Quote.count

  def self.get_quote
    if @@reloaded_at < 1.day.ago
      @@reloaded_at = DateTime.current
      @@quote_count = Quote.count
    end
    Quote.offset(rand(@@quote_count)).take
  end

  def get_local_quote
    # localize here
    text
  end

  def get_local_attribution
    # localize here
    attribution
  end
end
