# README #

The CoLab system provides instructor support for collaborative learning groups. In its current state, it deploys successfully to Heroku with Amazon SES & S3, Scheduler and JAWS Maria DB add-ons. It should run in a paid dyno with SSL enabled or a configuration change would be required.

## What is this repository for? ##

* The CoLab system which is based upon and supports the continued research of Micah Gideon Modell, Ph.D.
* Version: 3

## How do I get set up? ##

This system can be set up for development and testing on any modern desktop OS. I am using both [Linux Mint](https://www.linuxmint.com/download.php) and [Bash on Ubuntu on Windows](https://msdn.microsoft.com/en-us/commandline/wsl/install_guide) because I'm comfortable using the command line. That's just for context - GUIs can be powerful too and I can help you set them up if you run into difficulty.

At a minimum, you will need to install git and a text editor (I use vi, but there are tons of GUI editors like Notepad++ -- which is good and fee) to contribute. However, to do actual testing, you'll want ruby, ruby on rails, mariadb (mysql would also work). Deployment will require the Heroku toolbelt. Follow the installation instructions for your OS:

### Contributing ###

* [Official git page](https://git-scm.com/) [Windows](https://git-for-windows.github.io/) (other platforms are easy and I can help, but they're not worth listing here).
* [Notepad++](https://notepad-plus-plus.org/download/v7.3.3.html)
* [Learn Cucumber](https://cucumber.io/docs)
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### Testing ###
* [rvm (does not work in regular Windows)](http://rvm.io/)
* [ruby 2.4.2 (use rvm to install if not on Windows)](https://www.ruby-lang.org/en/downloads/)
* [MariaDB](https://mariadb.org/download/)
    * Create `colab_dev` and `colab_test` databases
    * Create a `test` user with `test` for the password
    * Make sure the user is enabled and has full access to the 'colab_dev' and `colab_test` databases
* clone this repository 'git clone https://<your bitbucket ID>@bitbucket.org/_performance/colab.git'
* Enter the new `CoLab` directory
* `gem install bundler`
* `bundle install`
* `rake db:create db:schema:load db:seed`

### Deployment ###
* [Heroku Toolbelt](https://devcenter.heroku.com/articles/heroku-cli)
* [Configure an Amazon SES SMTP Account](https://www.sitepoint.com/deliver-the-mail-with-amazon-ses-and-rails/)
    * heroku config:set SES_SMTP_USERNAME=<your username>
    * heroku config:set SES_SMTP_PASSWORD=<your password>

# Contribution instructions #
* Review the issues
* Find one that interests you
* Assign it to yourself
* Start working in your own branch
    * `git br <enter_new_branch_name>`
    * `git co <enter_new_branch_name>`
* Use `rails s` to run the server
* Open [the test server](http://localhost:3000)
* Play with it to understand the problem
    * Create your own user account
    * Execute `rake testing:set_admin['true','<your email>']` to make yourself an admin
* Start writing tests
* Run your tests
    * `rake cucumber:rerun`
* Check in your code
    * `git add <file name>`
    * `git checkin`
    * `git push`

### Who do I talk to? ###

* @micah_gideon
* Ask on [Slack](https://suny-k.slack.com/messages/G4DNHKPMM)
