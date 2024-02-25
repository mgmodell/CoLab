# frozen_string_literal: true

Given(/^the user is any student in the course$/) do
  @user = @course.rosters.enrolled.sample.user
end

Then(/^the user clicks the link to the concept list$/) do
  wait_for_render
  step 'the user switches to the "Task View" tab'

  find(:xpath, "//tbody/tr/td[@role='cell' and text()='#{@bingo.get_name(@anon)}']").click

  wait_for_render
  # current_path = page.current_path

  # page.should have_content 'Terms list for review'
  # x = page.find(:xpath, "//div[@data-react-class='BingoBuilder']")

  # props_string = x['data-react-props']
  page.find( :xpath, "//ul[@role='tablist']/li[contains(.,'Bingo game builder')]" ).click

  # props = JSON.parse(HTMLEntities.new.decode(x['data-react-props']))

  # url = "#{bingo_concepts_path(@bingo.id)}.json"
  # visit url

  chips = all(:xpath, "//div[contains(@id,'concept_')]")
  @concepts = chips.collect { |chip| { id: chip[:id], name: chip.text } }

  # visit current_path
end

Then(/^the concept list should match the list$/) do
  concept_names = @concepts.collect { |concept| concept[:name] }

  @bingo.concepts.where('concepts.id > 0').uniq.each do |concept|
    concept_names.include?(concept.name).should be true
    # page.find(:xpath, "//tr[@id='concept']/td[text()='#{concept.name}']").should_not be_nil
  end
end

Then(/^the user should see (\d+) concepts$/) do |concept_count|
  # Add a concept to compensate for the fake '*' square
  @concepts.count.should eq concept_count.to_i
end

Then(/^the number of concepts is less than the total number of concepts$/) do
  page.all(:xpath, "//tr[@id='concept']").count.should be < Concept.count
end

Then 'remember {int} group members' do |count|
  @group_members = @users.sample count
end

When 'the user is remembered group member {int}' do |index|
  @user = @group_members[index - 1]
end

Then 'the user remembers group performance' do
  @performance = page.find(:xpath, "//span[@id='performance']").text
end

Then 'the users performance matches original group performance' do
  @performance.should eq page.find(:xpath, "//span[@id='performance']").text
end

Then 'the user is added to the course' do
  @course.add_students_by_email @user.email
end

Then 'the cached performance is erased' do
  cl = @bingo.candidate_list_for_user(@user)
  cl.cached_performance = nil
  cl.save
  log cl.errors.full_messages unless cl.errors.empty?
end
