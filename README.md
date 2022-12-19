# README #

The CoLab system provides instructor support for collaborative learning
groups. In its current state, it deploys successfully to Heroku with
Amazon SES & S3 (using ActiveStorage), Scheduler and JAWS Maria DB add-ons with a libVips
buildpack. It should run in a paid dyno with SSL enabled or a configuration
change would be required.

## What is this repository for? ##

The CoLab system which is based upon and supports the continued
research of Micah Gideon Modell, Ph.D.

## How do I get set up? ##

This system can be set up for development and testing on any modern
desktop OS. It requires [Docker](https://www.docker.com/)
[git](https://git-scm.com/) and [bash](https://www.gnu.org/software/bash/)
support (native on MacOSX and Linux but may require additional
download/installation on Windows).

### Setting up ###
* (Recommended) Set up ssh-keys on [Bitbucket](https://bitbucket.org/account/settings/ssh-keys/)
* Open a terminal and navigate to a directory where you'd like to
  download the project.
* Run `git clone git@bitbucket.org:_performance/colab.git`
* Run `./buildContainers.sh`

The following two scripts are used to launch the development/testing
server for manual testing and to launch the automated tests
(respectively). Running either without any parameters will give you a
full guide::
* `dev_serv.sh` - Get started by using the `-j` option to load a basic
  test dump and the `-s` option to start the server on
  [http://localhost:3000](http://localhost:3000).
* `run_tests.sh` - Start with the `-c` option to make sure the database
  exists, then the `-r` option will kick off the process - warning it
  runs for nearly a day.

# Contribution instructions #
* Review the issues
* Find one that interests you
* Assign it to yourself
* Start working in your own branch
    * `git branch <enter_new_branch_name>`
    * `git checkout <enter_new_branch_name>`
* Create what you need
    * Create your own user account (if auth is working)
    * `rake testing:set_admin['true','<email>']` will create new admin accounts with password 'password'
    * `rake testing:examples['<email>']` will create some courses and activities for the specified user
* Open [the test server](http://localhost:3000)
* Play with it to understand the problem
* Start writing tests
* Run your tests (this may not work on all systems)
    * `rake cucumber:rerun`
* Check in your code
    * `git add <file name>`
    * ``git commit -m `<meaningful message>` ``
    * `git push`

### Who do I talk to? ###

* @micah_gideon
* Ask on [Slack](https://suny-k.slack.com/messages/G4DNHKPMM)
