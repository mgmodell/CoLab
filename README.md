![GitHub commit activity](https://img.shields.io/github/commit-activity/y/mgmodell/CoLab?style=flat-square)
![GitHub language count](https://img.shields.io/github/languages/count/mgmodell/CoLab)
[![CucumberReports: CoLab](https://messages.cucumber.io/api/report-collections/8e5bd8ab-b12f-460d-85ff-861b1b841ad6/badge)](https://reports.cucumber.io/report-collections/8e5bd8ab-b12f-460d-85ff-861b1b841ad6)

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
download/installation on Windows). The current configuration uses [devContainers](https://containers.dev/) and I am using [VSCode](https://code.visualstudio.com/) for development. I recommend it. The instructions below assume the docker and vsCode are already installed.
If you're installing Ubuntu, be sure to use the apt package for Docker rather than the snap version. Uninstall the snap version if it's present.

### Setting up ###
1. You must have mysqlshow installed for the tests to run properly. This is contained in and should be available via [homebrew](https://brew.sh/)(on a Mac) or `apt` or whatever package manager you're using:
    1. mariadb-client
    1. mysql-client
1. (**Recommended**) Set up ssh-keys on [GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).
1. Open a terminal and navigate to a directory where you'd like to
  download the project.
1. Run `git clone https://github.com/mgmodell/CoLab.git` (`git clone git@github.com:mgmodell/CoLab.git` if you've set up ssh-keys)
1. Navigate to the colab directory
1. Run `./buildContainers.sh`
1. Run `./db_load.sh -j`
1. Open [vsCode](https://code.visualstudio.com) and do the rest from there.
1. Run `./dev_serv.sh -e "haccess[`<yourEmail@something.com>`]"` to set
up the testing user with your email and a password of 'password' for
testing purposes.
1. Run `./dev_serv.sh -s` to start up the server.
  1. Open http://localhost:3000 or use a [VNC application](https://en.wikipedia.org/wiki/VNC) to open [vnc://localhost:5909](vnc://localhost:5909)

The `dev_serve.sh` script is used to interact with the development/testing environment and it is recommended that you run each to see what options are available:

If you want to run the full suite of tests, you will use `run_tests.sh` and it:
* Should be run from a terminal outside vsCode.
* Offers a listing of its features if run with no options.

# Contribution instructions #
1. Review the issues
1. Find one that interests you
1. Assign it to yourself
1. Start working in your own branch
    * `git branch <enter_new_branch_name>`
    * `git checkout <enter_new_branch_name>`
1. Create what you need
    * Create your own user account (if auth is working)
    * Run `./dev_serv.sh -e "haccess[`<yourEmail@something.com>`]"`
    * Run `./dev_serv.sh -e "examples[`<yourEmail@something.com>`]"`
1. Open [the test server](http://localhost:3000)
1. Play with it to understand the problem
1. Start writing tests
1. Check in your code
    * `git add <file name>`
    * ``git commit -m `<meaningful message>` ``
    * `git push`

### Who do I talk to? ###

* @micah_gideon
* Ask on [Slack](https://mountsaintmarycollege.slack.com/archives/G01269L9DAT)

## Contributors
My wife, Misun, and my two children have been instrumental in making this possible by putting up with me throughout.
