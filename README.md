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

Note, these instructions will assume you have ezproxy setup in /usr/local/ezproxy.  If you don't, just remember to change that in the following examples

### Set up directory

You will need a directory to contain the various ezproxy files. stanza-per-file  `mkdir /usr/local/ezproxy/conf.d`

### Checkout ezproxy-collaborate on your ezproxy machine (requires git to be installed for now)

````
cd ~
git clone - https://github.com/UIUCLibrary/ezproxy-collaborate.git
cd ezproxy-collaborate
````

Copy ezproxy-collaborate.cfg.skel to ezproxy-collaborate.cfg
Edit ezproxy-colloborate.cfg and change the entry to reflect the current ezproxy conf.d directory you created above
````
ezproxy_config_dir = /usr/local/ezproxy/conf.d
stanzas_include   = /usr/local/ezproxy/stazas_include.cfg
````

### Modify the ezproxy config.txt 

Add the line
````
IncludeFile /usr/local/ezproxy/stanzas_include.cfg
````
to the config.txt file.


Then run `bin/generate-stanzas.pl` to create templates

## Important files and file naming conventions

* stanzas.cfg has the institutional-specific information, such as passwords
* templates are found in local and vendor, more on that below
* template files end with either .template or _i.template. Use _i.template (ex. Books24x7_i.template) when there's information that will need to be supplied by the stanzas.cfg file. This way the generate-confgs.pl script can warn folks when they haven't added the corresponding stanza.
* Files in conf.d should end in .stanza
* stanzas_include.cfg - Apparently EzProxy doesn't allow for wildcards in the INcludeFile directive. However, you can include a file of IncludeFile. So the program always overwrites this file with the latest listings. Any additional stanzas added to conf.d but not in the templates should be included either in config.txt or in separate file.


## identify_unnecessary_lines.pl

Usage: `bin/identify_unnecessary_lines.pl config.txt > config_marked`

This is a utility script, which is still pretty rudimentary, that will process the given ezproxy file and the produced stanza files and output the ezproxy file w/ lines contained in the stanzas prefixed with...
`### in template #`.

Note this is really mean to help the process of migrating from one central config.txt file to a smaller config.txt file and files in conf.d. At this point it's highly, highly recommended to have a human being look through the file and figure out which commented sections can be taken out.

Right now this process ignores files w/ Option in them as well as lines of comments and whitespaces.


## local and vendor directory.

Right now there's a vendor directory containing templates from various sources, it might look something like:

* vendor/
  * oclc/
  * ebsco/

You don't need to modify these files if you want to override them, instead you can create a local directory. Copy the vendor file in their and modify it.

You can even remove local from the .gitingore file and keep track of those local changes.

Any file in local with the same name as a file in vendor will "override" the vendor template. (The first instance of that file name in the vendor directories will override any following ones).

Right now the convention of numerical prefixes can make this a bit tricky, so be careful there. That might change based on user request.


## Goals 

Overall goal - a system that makes it easy to update and maintain ezproxy stanzas.
 
* Ability to have a list of what resources need to have stanzas / be updated
* be cron / scheduled task friendly for updates
* maybe have limited web interface 
* wrap some common git operations, such as git pull
* voting on configurations
* possibly different configurations that could be chosen (so resource id + config id)
* interactive filling out of template (with help info?)
* When updating, review changes to stanzas (both in what was updated and differences in files), possible also allow to preview changes
* default to verbose, with way to turn off for cron
* Consider having a Rails-esque convention w/ local and vendor directories, local overriding vendor
* institutional-specific config in json
* Puppet compatible 

## Some possible future interaction/use

### Command line package-esque interactions
Update everything
` stanza update `

Update a particular stanza
` stanza update books24x7 `

Add a new resource to have stanzas
` stanza add acm `

See differences from current setup and future one (dry run)
` stanza preview  `

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

