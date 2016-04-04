# Ezproxy Collaborate

Ezproxy Collaborate is a community-shared git archive of EzProxy database stanzas with tools for install and deploying the configuration changes.


##Requirements

* Perl installed (list of required modules below, can use cpan tool to install)
  * Text::Template
  * Config::General
  * File::Spec (should be part of most installs)
* EzProxy Installed

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

### Checkout ezproxy-collobrate on your ezproxy machine (requires git to be installed for now)

````
git clone - needrepourl
cd ezproxy-collaborate
````

Copy ezproxy-collaborate.cfg.skel to ezproxy-collaborate.cfg
Edit ezproxy-colloborate.cfg and change the entry to reflect the current ezproxy conf.d directory you created above
````
ezproxy_config_dir = $EZPROXY_HOME/conf.d
stanzas_includee   = $EZPROXY_HOME/stazas_include.cfg
````

### Modify config.txt 

Add the line
````
IncludeFile $EZPROXY_HOME/stanzas_include.cfg
````
to the config.txt file.


Then run `bin/generate-stanzas.pl` to create templates

## Important files and file naming conventions

* stanzas.cfg has the institutional-specific information, such as passwords
* template files end with either .template or _i.template. Use _i.template (ex. Books24x7_i.template) when there's information that will need to be supplied by the stanzas.cfg file. This way the generate-confgs.pl script can warn folks when they haven't added the corresponding stanza.
* Files in conf.d should end in .stanza
* stanzas_include.cfg - Apparently EzProxy doesn't allow for wildcards in the INcludeFile directive. However, you can include a file of IncludeFile. So the program always overwrites this file with the latest listings. Any additional stanzas added to conf.d but not in the templates should be included either in config.txt or in separate file.


## Goals 

Overall goal - a system that makes it easy to update and maintain ezproxy stanzas.
 
* Ability to have a list of what resources need to have stanzas / be updated
* be cron / scheduled task friendly for updates
* maybe have limited web interface 
* wrap some common git operations, such as git pull
* voting on configurations
* possibly different configurations that could be chosen (so resouarce id + config id)
* interactive filling out of template (with help info?)
* When updating, review changes to stanzas (both in what was updated and differences in files), possible also allow to preview changes
* default to verbose, with way to turn off for cron
* Consider having a Rails-esque convention w/ local and vendor directories, local overriding vendor
* institutional-specific config in json
* Puppet compatible 

## Some possible future interaction/use

### Command line package-esque interactions
Update everything
` $> stanza update `

Update a particular stanza
` stanza update books24x7 `

Add a new resource to have stanzas
` stanza add acm `

See differences from current setup and future one (dry run)
` stanza preview  `SS

Suggest a new template
` stanza suggest id filename `


### Possible interaction when stanza requires institutional-specific info
```
$> stanza add books24x7
adding books24x7
books24x7 requires some institutional information
Do you want to supply that now (y/n) ?
$> y
Please supply SiteIdentifier (or m for more info)?
$> m
SiteIdentifier - Supplied  by Books24x7
TokenKey       - Secret only you know  
TokenSignatureKey - Some other secret{$TokenSignatureKey}

Please supply SiteIdentifier (or m for more info)?
$> BlahBlahBlah
Please supply TokenKey (or m for more info)?
$> MoreBlah
Please supply TokenSignatureKey (or m for more info)?
$> BlahBlahBlah
done adding books24x7

