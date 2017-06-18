class Quote < ActiveRecord::Base

  @@reloaded_at = DateTime.current
  @@quote_count = Quote.count

  def self.get_quote
    if @@reloaded_at < 1.day.ago
      @@reloaded_at = DateTime.current
      @@quote_count = Quote.count
    end
    Quote.offset( rand( @@quote_count ) ).take

  end
end
