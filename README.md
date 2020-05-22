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
desktop OS. I am using [Mac OS](http://www.Apple.com), [Linux
Mint](https://www.linuxmint.com/download.php) and [Ubuntu on
Windows](https://wiki.ubuntu.com/WSL) because I'm comfortable using the
command line. That's just for context - GUIs can be powerful too and I
can help you set them up if you run into difficulty.


### Contributing ###

* [Visual Studio Code](https://code.visualstudio.com/download) - I recommend this for development
* [Learn Cucumber](https://cucumber.io/docs)
* [Xcode -- if you're using Mac](https://developer.apple.com/xcode/)
* Set up your environment:
    * Install Ubuntu on [WSL](https://wiki.ubuntu.com/WSL) - use the Windows Store if you can
    * Install [VcXsrv](https://sourceforge.net/projects/vcxsrv)
    * Launch Ubuntu (set up a username/password)
    * `mkdir dev`
    * `cd dev`
    * `ssh-keygen` (press enter for all questions)
    * ``eval `ssh-agent` ``
    * `ssh-add ~/.ssh/id_rsa`
    * `cat ~/.ssh/id_rsa.pub`
* Copy the output of the above command (`cat`)
* Open [Bitbucket settings](https://bitbucket.org/account/settings/ssh-keys/)
* Add Key
* Paste the output into the window
* Save
* Back in Ubuntu:
    * `git clone git@bitbucket.org:_performance/colab.git`
    * `cd colab`
    * `/bin/sh setup` [enter your password when it is requested]



# Contribution instructions #
* Review the issues
* Find one that interests you
* Assign it to yourself
* Start working in your own branch
    * `git branch <enter_new_branch_name>`
    * `git checkout <enter_new_branch_name>`
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
    * `git commit -m ``<meaningful message>```
    * `git push`

### Who do I talk to? ###

* @micah_gideon
* Ask on [Slack](https://suny-k.slack.com/messages/G4DNHKPMM)
