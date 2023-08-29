
How to use:
1) Create a free account in AWS
2) Create a IAM user with perrmisson to create lambda, s3, dynamoDB, cloudfront. download profiles details
3) Make named profile on your terminal
4) Go to terraform folder and change "profile" "region" and "project_name" in global.tfvars.json and test-job.tfbackend
5) Go to bootstrap folder and run and run commands to apply
6) Go to main folder and run commands to apply
7) To see outpot url you can run "terraform output cloudfront_url from main folder" 
8) Go to cloudfront_url and use "user" and "pass" to login 
9) to increase number you need to go to $cloudfront_url/increase?i=10 (example: https://d30dsl436jpca3.cloudfront.net/increase?i=10)

in that scenario autorization impelemnted by lambda edge and cloudfront but there is a lot of other ways to do that we cam make autorization by arn, allow access to lambda only from some ip (with SG), use cognito with API Gateway, 

if you want to desstroy created resources you need to run commands to destroy

commands to apply:
terraform init -backend-config=../test-job.tfbackend -reconfigure
terraform apply -var-file "./terraform.tfvars.json" -var-file "../global.tfvars.json"

comands to destroy:
terraform init -backend-config=../test-job.tfbackend -reconfigure
terraform destroy -var-file "./terraform.tfvars.json" -var-file "../global.tfvars.json"
