[![Join the chat at https://gitter.im/bjschafer/brewmaster](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/bjschafer/brewmaster?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Brewmaster is still under heavy development! Don't use it unless you like broken things :)

YES it works with Linuxbrew.

Why?
----

Why not?

But seriously, Homebrew is a fantastic thing. Why shouldn't enterprises or people with multiple computers take advantage of it?  This way, all you need is this small program and a file which declares the things you want.  It's super easy to set up a new system - Brewmaster will even install Homebrew and its dependencies for you!

Installation
------------
Have the path to your YAML config file handy - the installer will want it.  You may want to put it in `/usr/local/brewmaster/` on Mac or `~/.linuxbrew/brewmaster/` on Linux, as that directory belongs to Brewmaster.

Then, you should just be able to run `./install.sh` and it'll figure itself out.

Goals
-----
First, make the things work.

Then, set it up to automatically keep its config up to date (using `git` of course) with your master config - one config location, many computers.

Next, I'd like to integrate fully with `brew cask` to be able to manage _all_ applications and not just developer tools.

Finally, why not integrate with actual system configuration?  Then all you have to do on an new system is install brewmaster and you're set!

Other Misc Thoughts
-------------------
Hierarchical config files - have one managed globally by the administrator but if the user is a developer and wants his own packages to be managed (automatically pinned/installed/etc), let them specify that.  Of course the global config takes precedence.

YAML file format
----------------

````````yaml
---
formulae: 
        - name: cask
          version: 0.53.1
          args: [arg1, arg2]

        - name: wget
          version: latest

        - name: cmake
          version: current
...

```

Note that you can specify a specific version which will be `brew pin`ed, `latest` which always installs the latest version available, or `current`, which `brew pin`s whichever version is available currently.

Right now the manual version specification isn't implemented, so I recommend using `current`.
