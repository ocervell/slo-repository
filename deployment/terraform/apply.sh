#!/bin/bash
tf13 workspace select $1
tf13 init
tf13 apply --auto-approve -var-file=$1.tfvars
