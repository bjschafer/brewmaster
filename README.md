YAML file format
----------------

````````yaml
formulae:
	- name: cask
	  version: 0.53.3
	  args: [arg1, arg2]

	- name: wget
	  version: latest

	- name: cmake
	  version: current
```

Note that you can specify a specific version which will be `brew pin`ed, `latest` which always installs the latest version available, or `current`, which `brew pin`s whichever version is available currently.

Right now the manual version specification isn't implemented, so I recommend using `current`.