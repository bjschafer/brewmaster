Brewmaster
==========

Brewmaster is a collection of scripts used to manage Homebrew on Mac from one unified config file.

Installation
------------
Have the path to your YAML config file handy - the installer will want it.  It will put it in `/usr/local/brewmaster/` on Mac or `~/.linuxbrew/brewmaster/` on Linux, as that directory belongs to Brewmaster.

Then, you should just be able to run `./install.sh` and it'll figure itself out.

YAML file format
----------------

```
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
