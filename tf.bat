@echo off 
echo %1
Set TF_LOG=INFO
Set  TF_LOG_PATH=./terraform.log
echo %TF_LOG%
if /i "%~1" == "init" (tf_init)
if /i "%~1" == "plan" (tf_plan) 
if /i "%~1" == "apply" (terraform apply) 
if /i "%~1" == "destroy"(terraform destroy) 