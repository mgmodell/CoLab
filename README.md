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
1. On Windows, you'll first want to install [Ubuntu on WSL2](https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-10#1-overview) (version 20.04 LTS or later should work just fine).
1. If you plan to run tests, you must have mysqlshow installed for the tests to run properly. This is contained in and should be available via [homebrew](https://brew.sh/)(on a Mac) or `apt` or whatever package manager you're using:
    1. mariadb-client
    1. mysql-client
1. (**Recommended**) Set up ssh-keys on [GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).
1. Open a terminal and navigate to a directory where you'd like to
  download the project.
1. Run `git clone https://github.com/mgmodell/CoLab.git` (`git clone git@github.com:mgmodell/CoLab.git` if you've set up ssh-keys)
1. Run `./buildContainers.sh`
1. Run `./dev_serv.sh -j` to load up anonymized testing data.
1. Run `./dev_serv.sh -e "haccess[`<yourEmail@something.com>`]"` to set
up the testing user with your email and a password of 'password' for
testing purposes.

The following two scripts are used to launch the development/testing
server for manual testing and to launch the automated tests
(respectively). Running either without any parameters will give you a
full guide::

* `dev_serv.sh` - Get started by using the `-j` option to load a basic
  test dump and the `-s` option to start the server on
  [http://localhost:3000](http://localhost:3000).
* `run_tests.sh` - Start with the `-c` option to make sure the database
  exists, then the `-r` option will kick off the process (*warning it
  runs for nearly a day*).

# Contribution instructions #
1. Review the issues
1. Find one that interests you
1. Assign it to yourself
1. Start working in your own branch
    * `git branch <enter_new_branch_name>`
    * `git checkout <enter_new_branch_name>`
1. Create what you need
    * Create your own user account (if auth is working)
    * `rake testing:set_admin['true','<email>']` will create new admin accounts with password 'password'
    * `rake testing:examples['<email>']` will create some courses and activities for the specified user
1. Open [the test server](http://localhost:3000)
1. Play with it to understand the problem
1. Start writing tests
1. Run your tests (this may not work on all systems)
    * `rake cucumber:rerun`
1. Check in your code
    * `git add <file name>`
    * ``git commit -m `<meaningful message>` ``
    * `git push`

### Who do I talk to? ###

* @micah_gideon
* Ask on [Slack](https://mountsaintmarycollege.slack.com/archives/G01269L9DAT)
