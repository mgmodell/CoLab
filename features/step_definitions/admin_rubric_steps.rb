# frozen_string_literal: true

Given('there are {int} {string} rubrics starting with {string}') do |count, is_published, prefix|
  school = School.find(1)
  count.times do |index|
    rubric = school.rubrics.new(
      name: "#{prefix} #{index}",
      description: Faker::GreekPhilosophers.quote,
      published: 'published' == is_published,
      user: @user
    )
    rubric.save
    log rubric.errors.full_messages if rubric.errors.present?
  end
end

Given('the user has one rubric named {string}') do |name|
  @rubric = @user.rubrics.new(
    name: name,
    description: Faker::GreekPhilosophers.quote,
    school: @user.school
  )
  log @rubric.errors.full_messages if @rubric.errors.present?
end

Then('retrieve the {string} rubric') do |whichRubric|
  @rubric = if( 'latest' == whichRubric )
              Rubric.last
            else
              Rubric.find_by_name whichRubric
            end
end

Then('the rubric {string} is {string}') do |field, value|
  case field.downcase
  when 'name'
    @rubric.name.should eq value
  when 'description'
    @rubric.description.should eq value
  else
    true.should be false
  end

end

Then('the user sees {int} rubrics') do |count|
  rubrics = find(:xpath, "//div[contains(@class,'MuiDataGrid-row')]" )
  rubrics.size.should eq count
end

Then('the user sets criteria {int} {string} to {string}') do |criteria_num, field, value|
  fields = find(:xpath, "//div[contains(@class,'MuiDataGrid-row')][#{criteria_num - 1}]/div[@data-field='#{field.downcase}']/div")
  fields.size.should eq 1
  fields[0].click
  fill_in fields[0], with: value, fill_options: {clear: [[:control, 'a'], :delete]}
end

Then('the user sets criteria {int} level {int} to {string}') do |criteria_num, level, value|
  fields = find(:xpath, "//div[contains(@class,'MuiDataGrid-row')][#{criteria_num - 1}]/div[@data-field='l#{level}_description']/div")
  fields.size.should eq 1
  fields[0].click
  fill_in fields[0], with: value, fill_options: {clear: [[:control, 'a'], :delete]}
end

Then('the user sees the criteria {int} weight is {int}') do |criteria_num, weight|
  fields = find(:xpath, "//div[contains(@class,'MuiDataGrid-row')][#{criteria_num - 1}]/div[@data-field='weight']/div")
  fields.size.should eq 1
  fields[0].textContent.to_int.should eq weight
end

Then('the user adds a new criteria') do
  click_button 'New Criteria'
end

Then('the user will see an empty criteria {int}') do |int|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sets criteria {int} {string} to to {string}') do |criteria_num, field_name, value|
  fields = find(:xpath, "//div[contains(@class,'MuiDataGrid-row')][#{criteria_num - 1}]/div[@data-field='#{field_name}']/div")
  fields.size.should eq 1
  fields[0].click
  fill_in fields[0], with: value, fill_options: {clear: [[:control, 'a'], :delete]}
end

Then('the user sets the criteria {int} weight to {int}') do |criteria_num, weight|
  fields = find(:xpath, "//div[contains(@class,'MuiDataGrid-row')][#{criteria_num - 1}]/div[@data-field='weight']/div")
  fields.size.should eq 1
  fields[0].click
  fill_in fields[0], with: weight, fill_options: {clear: [[:control, 'a'], :delete]}
end

Then('retrieve the {string} rubric from the db') do |name|
  @rubric = Rubric.find_by_name name
end

Then('the user is the owner of the rubric') do
  @rubric.user.should eq @user
end

Then('the rubric version is {int}') do |version|
  @rubric.version.should eq version
end

Then('the rubric {string} field is {string}') do |field_name, value|
  case field_name.downcase
  when 'description'
    @rubric.description.should eq value
  when 'name'
    @rubric.name.should eq value
  else
    true.should be false
  end
end

Then('the rubric criteria {int} {string} is {string}') do |criteria_num, field_name, value|
  criteria = @rubric.criteria[ criteria_num - 1 ]
  case field_name.downcase
  when 'description'
    criteria.description.should eq value
  else
    true.should be false
  end
end

Then('the rubric criteria {int} level {int} is {string}') do |criteria_num, level, value|
  criteria = @rubric.criteria[ criteria_num - 1 ]
  case level
  when 1
    criteria.l1_description.should eq value
  when 2
    criteria.l2_description.should eq value
  when 3
    criteria.l3_description.should eq value
  when 4
    criteria.l4_description.should eq value
  when 5
    criteria.l5_description.should eq value
  else
    true.should be false
  end


end

Then('the rubric criteria {int} weight is {int}') do |criteria_num, weight|
  criteria = @rubric.criteria[ criteria_num - 1 ]
  criteria.weight.should eq weight
end

Then('the rubric criteria {int} {string} to to {string}') do |int, string, string2|
# Then('the rubric criteria {float} {string} to to {string}') do |float, string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric criteria {int} level {int} to {string}') do |int, int2, string|
# Then('the rubric criteria {int} level {float} to {string}') do |int, float, string|
# Then('the rubric criteria {float} level {int} to {string}') do |float, int, string|
# Then('the rubric criteria {float} level {float} to {string}') do |float, float2, string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user searches for {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user edits the rubric') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric {string} published') do |is_published|
  @rubric.published.should eq ('is' == is_published )
end

Given('the {string} rubric is published') do |name|
  rubric = Rubric.find_by_name name
  rubric.is_published = true
  rubric.save
end

Then('the user copies the {string} rubric') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric {string} is {int}') do |string, int|
# Then('the rubric {string} is {float}') do |string, float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric owner {string} the user') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the rubric parent is {string} {string} {int}') do |string, string2, int|
# Then('the rubric parent is {string} {string} {float}') do |string, string2, float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the {string} rubric has {int} criteria') do |string, int|
# Then('the {string} rubric has {float} criteria') do |string, float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user adds a level to criteria {int}') do |int|
# Then('the user adds a level to criteria {float}') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('remember the data for criteria {int}') do |int|
# Then('remember the data for criteria {float}') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sees that criteria {int} matches the remembered criteria') do |int|
# Then('the user sees that criteria {float} matches the remembered criteria') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user deletes criteria {int}') do |int|
# Then('the user delete's criteria {float}') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('criteria {int} matches the remembered criteria') do |int|
# Then('criteria {float} matches the remembered criteria') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user moves criteria {int} up {int}') do |int, int2|
# Then('the user moves criteria {int} up {float}') do |int, float|
# Then('the user moves criteria {float} up {int}') do |float, int|
# Then('the user moves criteria {float} up {float}') do |float, float2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user deletes the rubric') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user can not {string} the rubric') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('there exists a rubric published by another user') do
  pending # Write code here that turns the phrase above into concrete actions
end

Given('the existing rubric is attached to this assignment') do
  pending # Write code here that turns the phrase above into concrete actions
end