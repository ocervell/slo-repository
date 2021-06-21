#!/usr/bin/make
# WARN: gmake syntax
########################################################
# Makefile for $(NAME)
#
# useful targets:
#	make clean -- clean distutils
#	make coverage_report -- code coverage report
#	make flake8 -- flake8 checks
#	make pylint -- source code checks
#	make tests -- run all of the tests
#	make unittest -- runs the unit tests
########################################################
# variable section

NAME = "slo-repo"
SHELL := /bin/bash
########################################################

all: load_env flask-app-datadog flask-app-prometheus slo-generator online-boutique

load_env: 
	. .env

slo-generator: load_env
	slo-generator compute -f slos/slo-generator -c slos/config.yaml -e

flask-app-datadog: load_env
	slo-generator compute -f slos/flask-app-datadog -c slos/config.yaml -e

flask-app-prometheus: load_env
	slo-generator compute -f slos/flask-app-prometheus -c slos/config.yaml -e

online-boutique: load_env
	slo-generator compute -f slos/online-boutique -c slos/config.yaml -e

custom-example: load_env
	slo-generator compute -f slos/custom-example -c slos/config.yaml -e

.PHONY: all run
