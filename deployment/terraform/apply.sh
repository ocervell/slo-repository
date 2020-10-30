#!/bin/bash
tf13 workspace select $1
tf13 init
tf13 apply -var-file=$1.tfvars
