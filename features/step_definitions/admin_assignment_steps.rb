require 'chronic'

    Given('the course has an assignment named {string} with an {string} rubric named {string}') do |assignment_name, rubric_published, rubric_name|
        @rubric = @user.rubrics.new(
            name: rubric_name,
            description: Faker::GreekPhilosophers.quote,
            passing: 65,
            school: @user.school,
            published: 'published' == rubric_published
        )
        @rubric.save
        log @rubric.errors.full_messages if @rubric.errors.present?

        @assignment = @course.assignments.new(
            name: assignment_name,
            description: Faker::Quote.yoda,
            start_date:  4.months.ago ,
            end_date:  2.months.from_now ,
            rubric: @rubric
        )
        @assignment.save
        log @assignment.errors.full_messages if @assignment.errors.present?
    end
    
    Given('the assignment opening is {string} and close is {string}') do |start_date_string, end_date_string|
        @assignment.start_date = Chronic.parse(start_date_string)
        @assignment.end_date = Chronic.parse(end_date_string)

        @assignment.save
        log @assignment.errors.full_messages if @assignment.errors.present?
    end
    
    Then('the user sets the assignment {string} to {string}') do |string, string2|
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Then('retrieve the {string} assignment from the db') do |string|
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Then('the assignment {string} field is {string}') do |string, string2|
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Then('the assignment {string} field to {string}') do |string, string2|
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Then('the assignment {string} active') do |string|
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Then('the assignment {string} group capable') do |string|
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Then('the user sets the assignment project to the course project') do
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Then('the assignment project is the course project') do
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Then('the user sets the assignment rubric to {string}') do |string|
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Given('the course has an assignment') do
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Given('the assignment {string} group-capable') do |string|
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Given('the assignment first deadline is {string} and final is {string}') do |string, string2|
      pending # Write code here that turns the phrase above into concrete actions
    end
    
    Given('the assignment {string} active') do |string|
      pending # Write code here that turns the phrase above into concrete actions
    end