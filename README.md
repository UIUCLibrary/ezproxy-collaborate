# Ezproxy Collaborate

Ezproxy Collaborate is a community-shared git archive of EzProxy database stanzas with tools for install and deploying the configuration changes.


##Requirements

# Perl installed (list of required modules below, can use cpan tool to install)
## Text::Template
## Config::General
## File::Spec (should be part of most installs)
# EzProxy Installed

## How it works

Templates are stored for each database family or groups. Various scripts can be run to keep these templates updated. These templates plus a master config file will generate ezproxy configuration files in a conf.d directory in the ezproxy directory. Ezproxy, via an IncludeFile, will add these stanzas.

## Setup

Note, these instructions will refer to $EZPROXY_HOME, which is a placeholder for wherever you have ezproxy installed.

### Setting EzProxy Home to make the steps easier (optional)

if you are on a linux system running a bash shell, you can modify your ~/.bash_profile to include the following, replacign /usr/local/ezproxy with the path where the ezproxy binary exists.

````
EZPROXY_HOME = /usr/local/ezproxy
export EZPROXY_HOME
````

Then type `source ~/.bash_profile` to reload.

### Set up directory

You will need a directory to contain the various ezproxy files. stanza-per-file  `mkdir $EZPROXY_HOME/conf.d`

### Modify ezproxy.cfg

Add the line
````
IncludeFile $EZPROXY_HOME/conf.d/*stanza
````
to the ezproxy.cfg file.
### Checkout ezproxy-collobrate on your ezproxy machine (requires git to be installed for now)

````
git clone - needrepourl
cd ezproxy-collaborate
````

Copy ezproxy-collaborate.cfg.skel to ezproxy-collaborate.cfg
Edit ezproxy-colloborate.cfg and change the entry to reflect the current ezproxy conf.d directory you created above
````
ezproxy_config_dir = $EZPROXY_HOME/conf.d
````

Then run `bin/generate-stanzas.pl` to create templates






