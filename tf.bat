@echo off 
echo %1

if /i "%~1" == "apply" (terraform apply) 
if /i "%~1" == "destroy"(terraform destroy) 