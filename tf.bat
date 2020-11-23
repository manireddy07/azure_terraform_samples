@echo off 
echo %1

if /i "%~1" == "init" (tf_init)
if /i "%~1" == "plan" (tf_plan) 
if /i "%~1" == "apply" (terraform apply) 
if /i "%~1" == "destroy"(terraform destroy) 