#!/bin/bash
environment="$1"
if [ -z "$environment" ]
then
    echo "Usage: deploy.sh <environment> <aws_region>"
    exit 1
fi

aws_region="$2"
if [ -z "$aws_region" ]
then
    echo "Usage: deploy.sh <environment> <aws_region>"
    exit 1
fi

echo -e "\n+++++ Starting deployment +++++\n"

cd terraform
terraform init
if [ $? -ne 0 ]
then
    echo "terraform init failed"
    exit 1
fi

terraform workspace new $environment
terraform workspace select $environment

telegram_bot_token=`aws ssm get-parameter --region $aws_region --name "${environment}_telegram_bot_token" --output text --with-decryption | cut -f7`
if [ -z "$telegram_bot_token" ]
then
    printf "paste the telegram_bot_token: "
    read telegram_bot_token
fi

terraform apply --auto-approve \
    --var "region=$aws_region" \
    --var "telegram_bot_token=$telegram_bot_token"

echo -e "\n+++++ Deployment done +++++\n"