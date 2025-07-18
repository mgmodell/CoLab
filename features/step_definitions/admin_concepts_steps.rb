# frozen_string_literal: true

require 'faker'

Given( '{int} multi-word concepts have been added to the system' ) do | word_count |
  check_uniq = {}
  while check_uniq.keys.count <= word_count
    c_name = Faker::Company.industry
    check_uniq[c_name.downcase] = true
  end
  check_uniq.keys.each do | c_name |
    Concept.create name: c_name
  end
end

When( 'create a concept named {string}' ) do | concept_name |
  Concept.create name: concept_name
end

Then( 'a concept will exist named {string}' ) do | concept_name |
  Concept.where( name: concept_name ).count.should be 1
end

Then( 'a concept name is set to {string}' ) do | concept_case |
  @concept = Concept.where( 'id > 0' ).sample

  case concept_case
  when 'all lowercase'
    @concept_saved = @concept.name.downcase

  when 'all uppercase'
    @concept_saved = @concept.name.upcase
  else
    @concept_saved = @concept.name
    @concept_saved.length.times do | index |
      @concept_saved[index] = if rand( 2 ).positive?
                                @concept_saved[index].upcase
                              else
                                @concept_saved[index].downcase
                              end
    end
  end
  @concept.name = @concept_saved
  @concept.save
end

Then( 'the concept name is saved in standard form' ) do
  @concept.reload.name.should_not eq @concept_saved
  @concept.reload.name.should eq Concept.standardize_name name: @concept_saved
end

Then('the user updates the {string} concept to {string}') do |concept_old, concept_new|
  wait_for_render
  fill_in 'concept-search', with: concept_old[0..4]
  find( :xpath, "//tr/td[text()='#{concept_old}']" ).click
  fill_in 'conceptName', with: concept_new
  click_button 'update_concept'
end

Then('the concept {string} will be in the list') do |new_concept_name|
  wait_for_render
  fill_in 'concept-search', with: new_concept_name[0..4]
  find_all( :xpath, "//tr/td[text()='#{new_concept_name}']" ).size.should be 1
end

Then('a concept will not exist named {string}') do |old_concept_name|
  Concept.where( name: old_concept_name ).count.should be 0
end