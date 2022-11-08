# frozen_string_literal: true

require 'faker'

Given('{int} multi-word concepts have been added to the system') do |word_count|
  check_uniq = {}
  while check_uniq.keys.count <= word_count
    c_name = Faker::Company.industry
    check_uniq[c_name.downcase] = true
  end
  check_uniq.each_key do |c_name|
    Concept.create name: c_name
  end
end

When('create a concept named {string}') do |concept_name|
  Concept.create name: concept_name
end

Then('a concept will exist named {string}') do |concept_name|
  Concept.where(name: concept_name).count.should be 1
end

Then('a concept name is set to {string}') do |concept_case|
  @concept = Concept.where('id > 0').sample

  case concept_case
  when 'all lowercase'
    @concept_saved = @concept.name.downcase

  when 'all uppercase'
    @concept_saved = @concept.name.upcase
  else
    @concept_saved = @concept.name
    @concept_saved.length.times do |index|
      @concept_saved[index] = if rand(2).positive?
                                @concept_saved[index].upcase
                              else
                                @concept_saved[index].downcase
                              end
    end
  end
  @concept.name = @concept_saved
  @concept.save
end

Then('the concept name is saved in standard form') do
  @concept.reload.name.should_not eq @concept_saved
  @concept.reload.name.should eq Concept.standardize_name name: @concept_saved
end
