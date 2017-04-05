Given /^there is a course$/  do
  @course = Course.make
end

Then /^the user sets the project to the course's project$/  do
  page.select( @project.name, from: "Source of project groups" )
end

