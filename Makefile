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
	slo-generator -f slos/slo-generator -b slos/error_budget_policy.yaml --export

flask-app-datadog: load_env
	slo-generator -f slos/flask-app-datadog -b slos/error_budget_policy.yaml --export

flask-app-prometheus: load_env
	slo-generator -f slos/flask-app-prometheus -b slos/error_budget_policy.yaml --export

online-boutique: load_env
	slo-generator -f slos/online-boutique -b slos/error_budget_policy_ssm.yaml --export

custom-example: load_env
	slo-generator -f slos/custom-example -b slos/error_budget_policy.yaml --export

deploy:
	gsutil cp 

.PHONY: all run
