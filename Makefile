#!/bin/bash

############################################################
# QUICK START INSTRUCTIONS 
############################################################

# (1) Add project name and server auth details in .Makefile.config
# (2) $ make new_project
# (3) $ make
# (4) $ make 

############################################################
# Boilerplate 
############################################################

# http://clarkgrubb.com/makefile-style-guide

MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
testme:
	@echo "Test config"
DATENOW = `date +'%Y%m%d-%H-%M'`
TIMENOW = `date: '%Y%m%d %H:%M:%S'`

# Test project name, with a date to clarify
showname:
	@echo PROJECT_NAME `date +'%y-%m-%d-%H:%M'`

newtestfile:	
	rm -f -r tests
	mkdir -p tests
	cp 'test.png' "tests/test-$(DATENOW).png"

# File naming formats
vars-prefix := .Makefile.


########### INCLUDES ###############
# Include project variables
-include config/Makefile
# Include settings, variables, and config details from seperate files (for clarity)
-include $(vars-prefix)$(TARGET)


############################################################
# STEPS TO SETUP FOR A NEW PROJECT
############################################################

new_project:	create_project_dir	set_project_name	update_project_name	copy_environments_to_server	update_build_count git_all deploy
	@echo "New project setup: $(PROJECT_NAME)"
	@echo "Server directory setup at: $(PROJECT_HOME)"

# SETTING UP DEPLOYMENT
# set_project_name:
# - get the name specified in the .Makefile.config and pass it to the post-recieve HOOK
# - this makes changing the deployment directory, project name or 'client' name as simple as a one line change. 

set_project_name:
	sed -e s/default_project_name/$(PROJECT_NAME)/ $(INIT_BASE)$(DEV_ENV)/hooks/post-receive.default > $(INIT_BASE)$(DEV_ENV)/hooks/post-receive
	sed -e s/default_project_name/$(PROJECT_NAME)/ $(INIT_BASE)$(STAGING_ENV)/hooks/post-receive.default > $(INIT_BASE)$(STAGING_ENV)/hooks/post-receive
	sed -e s/default_project_name/$(PROJECT_NAME)/ $(INIT_BASE)$(PRODUCTION_ENV)/hooks/post-receive.default > $(INIT_BASE)$(PRODUCTION_ENV)/hooks/post-receive

update_project_name:	initialize_deployments setup_local_branches	set_project_name

create_project_dir:
	rsync -a $(SRC_BASE) $(PROJECT_HOME)


# Take all files in the git 'control' directories and move them to the server

copy_environments_to_server:	set_project_name
	rsync -a $(INIT_BASE) $(PROJECT_HOME)
	@echo "Server git deployment settings updated"

git_all:
	@git add -A :/
	@git commit -am "All modified files setup for $(PROJECT_NAME) build: $(LOCAL_BUILDCOUNT)"

############################################################
# RECEIPES
############################################################


deploy: dry-run
	@git push $(PROJECT_HOME_ENV) $(BRANCH)
# deploy: dry-run set_project_name copy_environments_to_server	

simpletest:
	@echo "Doing a test action"

# Output notification before taking action
# to do a test dry-run use "-anv" instead of "-a"
INCREMENT_OFFSET=0

dry-run:
	@echo "Deployment Details:"
	@echo "Project: $(PROJECT_NAME)"
	@echo "Host:   $(PROJECT_HOME_ENV)"
	@echo "Branch:  $(BRANCH)"
	@echo "Build:  $$(( $(LOCAL_BUILDCOUNT) - $(INCREMENT_OFFSET) ))"
	@echo "Tag:  $(TAG)"
	@for n in {3..1}; do printf "%s ... " $$n; sleep 1; done; echo	

# Protect filenames vs receipe names
# Examples: install build clean deploy git-prod git-staging prod staging
.PHONY: all production staging dev



