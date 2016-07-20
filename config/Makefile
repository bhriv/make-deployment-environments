#!/bin/bash
# Makefile.config
$(warning EXECUTING config) 

# When the command {$ make} is run what rules should be executed
all: update_build_count
TARGET ?= config

########################################################################################################
#
# ENVIRONMENT VARIABLES (all caps, with fallback)
#
# Setup your project by replacing the examples with actual variable
# Note as per official docs - "numbers, and underscores should be avoided" in variable names

# ---------------------------------------

PROJECT_NAME = myproject

# ---------------------------------------

# SERVER AUTH DETAILS

HOST_USER = myproject
HOST_ADDRESS = XX.XX.XX.XXX
HOST_PUBLIC_PATH = public_html

# ---------------------------------------

# Environment Naming Preferences - these shouldn't change

INIT_BASE = config/destination_server/
ENV_BASE = environments
SRC_BASE = public
DEV_ENV = $(ENV_BASE)/dev
STAGING_ENV = $(ENV_BASE)/staging
PRODUCTION_ENV = $(ENV_BASE)/production

# ---------------------------------------
# Help:

# (HOST_USER) User account on server. Usually, when using ssh, this will be nestled under a specific user NOT the root. 

# (HOST_ADDRESS) IP or URI

# (HOST_PUBLIC_PATH) Common examples of the directory connected to the public URL are 
# - root/public_html/
# - root/html/
# - home/var/www/

# (HOST_PROJECT_PATH) URL for this project www.example.com/staging
# DIRECTORY for this project will be 'root/public_html/staging'
# If the project will be installed in the public facing directory (i.e. If uses will access the site via www.example.com) 
# the HOST_PROJECT_PATH variable should be blank (e.g. HOST_PROJECT_PATH = )

# ---------------------------------------

# EXAMPLE 1: TARGET=staging will use the post-recieve deploy rules listed in: 
# lumious@70.32.82.199:~/public_html/src/environments/staging/hooks/post-receive
# and will deploy the project to be viewed at http://staging.lumious.com
# as the subdomain staging.lumious.com is rooted to the directory lumious@70.32.82.199:~/public_html/staging
# NOTE - the is a different directory to the git directory where the post-recieve hooks are stored


#########################################################################################################

DESTINATION_ENV ?= $(DEV_ENV)

export HOST_PROJECT_PATH = /$(PROJECT_NAME)
export SERVER_HOME = $(HOST_USER)@$(HOST_ADDRESS)
export DOMAIN_HOME = $(SERVER_HOME):~/$(HOST_PUBLIC_PATH)
export PROJECT_HOME = $(DOMAIN_HOME)$(HOST_PROJECT_PATH)
export GIT_HOOKS = $(INIT_BASE)$(DESTINATION_ENV)/hooks
export PROJECT_HOME_ENV = $(PROJECT_HOME)/$(DESTINATION_ENV)

# Hardcoded server address for debugging
projecthome:
	@echo "Domain home: $(PROJECT_HOME)"
home:
	@echo "Domain home: $(DOMAIN_HOME)"


# LOCAL Requirements
DESTINATION_DEV = $(PROJECT_HOME)/$(DEV_ENV)
DESTINATION_STAGING = $(PROJECT_HOME)/$(STAGING_ENV)
DESTINATION_PRODUCTION = $(PROJECT_HOME)/$(PRODUCTION_ENV)

# addp:
# 	git remote add $(PROJECT_NAME)-production $(DESTINATION_PRODUCTION)
# rmp:
# 	git remote rm $(PROJECT_NAME)-production

initialize_deployments:
	git remote add $(PROJECT_NAME)-production $(DESTINATION_PRODUCTION)
	git remote add $(PROJECT_NAME)-dev $(DESTINATION_DEV)
	git remote add $(PROJECT_NAME)-staging $(DESTINATION_STAGING)
	

clean_deployments:
	git remote rm $(PROJECT_NAME)-dev
	git remote rm $(PROJECT_NAME)-staging
	git remote rm $(PROJECT_NAME)-production

setup_local_branches:
	git branch $(PROJECT_NAME)-dev
	git branch $(PROJECT_NAME)-staging
	git branch $(PROJECT_NAME)-master

clean_local:
	git branch -D $(PROJECT_NAME)-dev
	git branch -D $(PROJECT_NAME)-staging
	git branch -D $(PROJECT_NAME)-master

# ---------------------------------------
# Help:
#

# If you get the error 'fatal: dev already exists' you can run:
# $git remote rm dev
# Example:
# git remote add production ssh://myproject@70.32.82.199:21/public_html/testdeploy


############################################################
# Setup Default .gitignore file and rules
############################################################

GITIGNORE= .gitignore
EXISTINGRULES=`cat $(GITIGNORE)`

### List boilerplate gitignore files and directories
define BOILERPLATE_GIT_IGNORE
/node_modules
/#Documents
/Z-graveyard
npm*
/.sass-cache
.codekit-cache
*.DS_Store
src/.tmp
public/.tmp
design/
safety-backups/
unused-files/
endef
# add all rules to object
define VARS
$(BOILERPLATE_GIT_IGNORE)
endef
export VARS
# write the new ignore rules to the .gitignore file
set_ignore_rules:
	@echo "$$VARS" > .gitignore

#### debugging only
# show_rules:
# @echo $(EXISTINGRULES)
# copy_rules: show_rules
#	@echo $(EXISTINGRULES) > gitcopy.txt
 
#### To add additional rules use the following steps (1) define (2) add new defined VAR2 into the 'define VARS' receipe
# 
# define VAR2
# $(EXISTINGRULES)
# endef


############################################################
# BUILD LOCAL ENVIRONMENT
############################################################
#
# Initialize the required empty directories for the various deployment environments
#
# Build directories for the project in the following structure:
#
# example_project_name/
# - src
# 	-- environments 
#		--- dev
#		--- staging
# 		--- production
#	-- test-Date.png
# - design
# - safety-backups
# - unused-files


initialize_dirs:
	@echo "Initializing directories"
	mkdir -p $(SRC_BASE) $(SRC_BASE)/.log $(SRC_BASE)/.tmp
	mkdir -p design 
	mkdir -p safety-backups
	mkdir -p unused-files
	mkdir -p .tmp

initialize_project:	set_ignore_rules	initialize_dirs	init_build_count
	@echo "Initializing Project"
	git init
	git add -A :/
	git commit -am "New Project Initialized called $(PROJECT_NAME)"

# Remote options (often set with TARGET)
# BRANCH ?= master
BRANCH ?= $(error Please specify which branch to deploy (e.g. The format should be BRANCH=projectname-master))
DEST   ?= $(error Please specify destination hosts (DEST))
TAG    ?= $(shell git rev-parse --short $(BRANCH)@{u})

############################################################
# Add A Local Build Tracker For Versioning
############################################################

BUILDCOUNT_INIT= .init/build-init.txt
INIT_BUILDCOUNT=`cat $(BUILDCOUNT_INIT)`

BUILDCOUNT= build-count.txt
export LOCAL_BUILDCOUNT=`cat $(BUILDCOUNT)`
SHELL=/bin/bash
INCREMENTBUILD=1

init_build_count:
	@echo $$(( $(INIT_BUILDCOUNT) + $(INCREMENTBUILD) )) > build-count.txt

update_build_count:
	@echo $$(( $(LOCAL_BUILDCOUNT) + $(INCREMENTBUILD) )) > build-count.txt
	cp 'build-count.txt' '$(SRC_BASE)/build-number.txt'
	@echo "Build Number:" $(LOCAL_BUILDCOUNT)


############################################################
# Setup Versioning and Local Build Logs
############################################################

LOGDIR = .init
VERSIONNUMBER = 0.0.1
VERSIONMSG = PROJECT_NAME VERSIONNUMBER

mdir: 
	mkdir -p .log

# update_version_log:
# 	cp $(INITDIR)/blank.txt > $(LOGDIR)/version-log.txt
# define BUILD_PROJECT_DETAILS
# Project: 
# $(PROJECT_NAME)
# endef

# define BUILD_TIMESTAMP
# Latest Build: 
# $(TIMENOW)
# endef

# define BUILD_LOG
# $(BUILD_PROJECT_DETAILS)
# $(BUILD_TIMESTAMP)
# endef
# export BUILD_LOG



