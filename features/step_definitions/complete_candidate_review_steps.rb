# frozen_string_literal: true

Given( 'the users {string} prep {string}' ) do | completion_level, group_or_solo |
  # Store the previous user (do no harm)
  temp_user = @user

  user_group = @users
  # If we're working with a group, as a group, then...
  if 'as a group' == group_or_solo
    collab_requested = false
    @users.each do | user |
      @user = user
      step 'the user "has" had demographics requested'
      step 'the user logs in'
      step 'user should see 1 open task'
      step 'the user clicks the link to the candidate list'
      step 'the user should see the Bingo candidate list'

      if !collab_requested
        step 'the user requests collaboration'
        collab_requested = true
      else
        step 'the user "accepts" the collaboration request'
      end

      step 'the user logs out'
    end
    user_group = [@users.sample]
  end

  @user = @users.sample
  step 'the user "has" had demographics requested'
  step 'the user logs in'
  step 'the user clicks the link to the candidate list'
  fields = page.all( :xpath, "//input[contains(@id, 'term_')]" ).count
  step 'the user logs out'

  # set up how much we want to complete
  case completion_level.downcase
  when 'finish'
    fields_to_complete = fields
  when 'incomplete'
    fields_to_complete = fields / 2
  when 'don\'t'
    fields_to_complete = 0
  else
    log "we didn't test anything here: #{completion_level}"
    true.should be false
  end

  user_group.each do | user |
    @bingo.transaction do
      cl = @bingo.candidate_list_for_user user
      @entries_lists = {} if @entries_lists.nil?
      @entries_lists[user] = [] if @entries_lists[user].nil?
      @entries_list = @entries_lists[user]

      fields_to_complete.times do | index |
        @entries_list[index] = {} if @entries_list[index].nil?
        @entries_list[index]['term'] = "#{Faker::Company.industry}_#{index}"
        @entries_list[index]['definition'] = Faker::Company.bs

        candidate = Candidate.new(
          candidate_list: cl,
          term: @entries_list[index]['term'],
          definition: @entries_list[index]['definition'],
          user:
        )
        candidate.save
        if candidate.errors.size.positive?
          log candidate.errors.full_messages
          true.should be false
        end
      end
    end
  end

  # Reset back to previous user (whomever that was)
  @user = temp_user
end

Then( /^the user sees (\d+) candidate items for review$/ ) do | candidate_count |
  wait_for_render
  # Enable max rows
  max_rows = @bingo.candidates.size
  find( :xpath, '//div[@data-pc-name="paginator"]/div[contains(@class,"dropdown")]' ).click
  find( :xpath, "//div[@data-pc-name='paginator']//li[contains(.,'#{max_rows}')]" ).click

  page.all( :xpath, "//input[contains(@id, 'feedback_4_')]", visible: :all )
      .count.should eq candidate_count.to_i
  # Latest UI only shows 'Concept' when relevant/available
  # page.all(:xpath, "//input[contains(@id, 'concept_4_')]")
  #    .count.should eq candidate_count.to_i
end

Given( /^the user sees review items for all the expected candidates$/ ) do
  @bingo.candidates.completed.each do | candidate |
    # Latest UI only shows 'Concept' when relevant/available
    # page.all(:xpath, "//input[@id='concept_4_#{candidate.id}']").count.should eq 1
    page.all( :xpath,
              # "//div[@id='feedback_4_#{candidate.id}']",
              "//input[@id='feedback_4_#{candidate.id}']",
              visible: false ).count.should eq 1
  end
end

Then( /^the user waits while seeing "([^"]*)"$/ ) do | wait_msg |
  wait_for_render

  counter = 0
  while page.has_text? wait_msg
    sleep 1
    counter += 1
    break if counter > 60
  end
end

Given( /^the user lowercases "([^"]*)" concepts$/ ) do | which_concepts |
  page.all( :xpath, "//input[contains(@id,'concept_4_')]" ).each do | concept_field |
    next unless ( 'all'.eql? which_concepts ) || rand( 2 ).positive?

    text = concept_field.value
    text.length.times do
      concept_field.send_keys :delete
    end
    concept_field.set concept_field.value.downcase
  end
end

Given( 'the user assigns {string} feedback to all candidates' ) do | feedback_type |
  wait_for_render
  # Enable max rows
  max_rows = @bingo.candidates.size
  find( :xpath, '//div[@data-pc-name="paginator"]/div[contains(@class,"dropdown")]' ).click
  find( :xpath, "//div[@data-pc-name='paginator']//li[contains(.,'#{max_rows}')]" ).click

  concept_count = Concept.count
  concepts = if concept_count < 2
               []
             else
               Concept.where( 'id > 0' ).collect( &:name )
             end

  concept_count.upto( concept_count + 3 ) do | counter |
    concepts << "concept #{counter}"
  end

  feedbacks = CandidateFeedback.unscoped.where( 'name_en like ?', "#{feedback_type}%" )
  @feedback_list = {}
  @bingo.candidates.completed.each do | candidate |
    feedback = feedbacks.sample
    @feedback_list[candidate.id] = { feedback: }
    concept = nil
    if 'term_problem' == feedback.critique
      @feedback_list[candidate.id][:concept] = ''
    else
      concept = concepts.rotate!( 1 ).first
      @feedback_list[candidate.id][:concept] = concept.split.map( &:capitalize ).*' '
    end

    # Set the feedback
    begin
      retries ||= 0
      xp_search = "//input[@id='feedback_4_#{candidate.id}']/following-sibling::div"

      find( :xpath, xp_search, visible: :all ).click
    rescue Selenium::WebDriver::Error::ElementNotInteractableError
      find( :xpath, xp_search, visible: :all ).send_keys :escape
      ( retries += 1 ).should be < 20, 'Too many retries'
      retry unless retries > 5
    rescue Selenium::WebDriver::Error::ElementClickInterceptedError
      find( :xpath, '//body' ).click
      ( retries += 1 ).should be < 20, 'Too many retries'
      retry unless retries > 5
    end

    begin
      xpth_search = "//li[contains(.,\"#{feedback.name}\")]"
      page.find( :xpath, xpth_search ).click
      begin
        if has_xpath?( xpth_search )
          page.find( :xpath, xpth_search ).click
          send_keys :enter
        end
      rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
        send_keys :escape
        ( retries += 1 ).should be < 20, 'Too many retries'
        retry unless retries > 5
      rescue Capybara::ElementNotFound => e
        send_keys :escape
        ( retries += 1 ).should be < 20, 'Too many retries'
        retry unless retries > 5
      end

      if concept.present?
        find( :xpath, "//span[@id='concept_4_#{candidate.id}']" ).click
        send_keys [:control, 'a'], :backspace
        send_keys [:command, 'a'], :backspace
        send_keys concept
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError => e
      puts e.message
      ( retries += 1 ).should be < 20, 'Too many retries'
      retry unless retries > 5
    rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
      # Nothing needed
      puts e.message
    rescue Selenium::WebDriver::Error::ElementClickInterceptedError => e
      elem = page.find( :xpath,
                        "//li[contains(.,\"#{feedback.name}\")]" )
      elem.scroll_to( elem )
      elem.click

      ( retries += 1 ).should be < 20, 'Too many retries'
      retry unless retries > 5
    rescue Capybara::ElementNotFound => e
      begin
        send_keys :enter
      rescue Selenium::WebDriver::Error::ElementNotInteractableError => e
        log 'Element not interactable error'
        log e
      end
    end
  end
end

Given( /^the saved reviews match the list$/ ) do
  @feedback_list.each do | key, value |
    #   puts "#{Candidate.find( key ).concept.name}|#{value[:concept]}"
    Candidate.find( key ).concept.name.should eq value[:concept] if value[:concept].present?
  end
end

Given( 'the user checks the review completed checkbox' ) do
  inpt = find( :xpath, "//div[@id='review_complete']//input[@type='checkbox']", visible: :all )

  find( :xpath, "//div[@id='review_complete']" ).click if 'true' != inpt[:checked]
end

Given( /^the user checks "([^"]*)"$/ ) do | checkbox_name |
  elem_id = find( :xpath, "//label[contains(.,'#{checkbox_name}')]" )[:for]
  find( 'div', id: elem_id ).click
end

Given( /^the user is the most recently created user$/ ) do
  @user = @users.last
end

When( /^the user clicks the link to the candidate review$/ ) do
  wait_for_render
  step 'the user switches to the "Task View" tab'
  find( :xpath, "//tbody/tr/td[contains(.,'#{@bingo.get_name( @anon )}')]" ).click

  wait_for_render

  # Enable max rows
  max_rows = @bingo.candidates.size
  find( :xpath, '//div[@data-pc-name="paginator"]/div[contains(@class,"dropdown")]' ).click
  find( :xpath, "//div[@data-pc-name='paginator']//li[contains(.,'#{max_rows}')]" ).click
end

Then( /^there will be (\d+) concepts$/ ) do | concept_count |
  # Adjusting for an entry for the seeded '*' concept
  Concept.count.should eq( concept_count.to_i + 1 )
end

Then( 'the user navigates home' ) do
  find( :id, 'main-menu-button' ).click
  find( :xpath, '//*[@id="home-menu-item"]' ).click
end
