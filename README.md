# System Design: 3-Tier Web App on AWS EKS

1. [Part 1](https://youtu.be/8-M2rK4NRyI)

## Provision the Infrastructure

### Set up your AWS client

First, ensure that you've configured your AWS CLI accordingly. Setting
that up is outside the scope of this guide so please go ahead and read
up at https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html


### Install Terraform

Grab the latest Terraform CLI [here](https://www.terraform.io/downloads.html)


### Initialize the Terraform Working Directory

```
cd <PROJECT-ROOT>

terraform -chdir=terraform init
```


### Create Your Environment-Specific tfvars File

```
cp terraform/example.tfvars terraform/terraform.tfvars
```

Then modify the file as you see fit.


### Create the DB Credentials Secret in AWS


```
secrets_dir=~/.relaxdiego/system-design
mkdir -p $secrets_dir
chmod 0700 $secrets_dir

aws_profile=$(grep -E ' *profile *=' terraform/terraform.tfvars | sed -E 's/ *aws_profile *= *"(.*)"/\1/g')
aws_region=$(grep -E ' *region *=' terraform/terraform.tfvars | sed -E 's/ *aws_region *= *"(.*)"/\1/g')
cluster_name=$(grep -E ' *env_name *=' terraform/terraform.tfvars | sed -E 's/ *cluster_name *= *"(.*)"/\1/g')
db_creds_secret_name=${cluster_name}-db-creds
db_creds_secret_file=${secrets_dir}/secrets/${cluster_name}-db-creds.json

cat > $db_creds_secret_file <<EOF
{
    "db_user": "SU_$(uuidgen | tr -d '-')",
    "db_pass": "$(uuidgen)"
}
EOF
chmod 0600 $db_creds_secret_file

aws secretsmanager create-secret \
  --profile "$aws_profile" \
  --name "$db_creds_secret_name" \
  --description "DB credentials for ${cluster_name}" \
  --secret-string file://$db_creds_secret_file
```


### Create a Route 53 Zone for Your Environment

First, get a hold of an FQDN that you own and define it in an env var:

```
route53_zone_fqdn=<TYPE-IN-YOUR-FQDN-HERE>
```

Let's also create a unique caller reference:

```
route53_caller_reference=$(uuidgen | tr -d '-')
```

Then, create the zone:

```
aws_profile=$(grep -E ' *profile *=' terraform/terraform.tfvars | sed -E 's/ *aws_profile *= *"(.*)"/\1/g')
aws_region=$(grep -E ' *region *=' terraform/terraform.tfvars | sed -E 's/ *aws_region *= *"(.*)"/\1/g')

aws route53 create-hosted-zone \
  --profile "$aws_profile" \
  --name "$route53_zone_fqdn" \
  --caller-reference "$route53_caller_reference" > tmp/create-hosted-zone.out
```

List the nameservers for your zone:

```
cat tmp/create-hosted-zone.out | jq -r '.DelegationSet.NameServers[]'
```

Now modify your DNS servers to use the hosts listed above.


### And We're Off!


```
terraform -chdir=terraform apply
```

Proceed once the above is done.


### (Optional) Connect to the Bastion for the First Time

Use [ssh4realz](https://github.com/relaxdiego/ssh4realz) to ensure
you connect to the bastion securely. For a guide on how to (and why)
use the script, see [this video](https://youtu.be/TcmOd4whPeQ).

```
ssh4realz $(terraform -chdir=terraform output -raw bastion_instance_id)
```


### Subsequent Bastion SSH Connections

With the bastion's host key already saved to your known_hosts file,
just SSH directly to its public ip.

```
ssh -A ubuntu@$(terraform -chdir=terraform output -raw bastion_public_ip)
```


### Clean Up Your Mess!

```
terraform -chdir=terraform destroy
```

If you no longer plan on bringing up this cluster at
a later time, clean up the following as well:

```
aws secretsmanager delete-secret \
  --force-delete-without-recovery \
  --secret-id "${cluster_name}-db-creds"

route53_zone_fqdn=<TYPE-IN-YOUR-FQDN-HERE>
route53_caller_reference=$(uuidgen | tr -d '-')
aws_profile=$(grep -E ' *profile *=' terraform/terraform.tfvars | sed -E 's/ *aws_profile *= *"(.*)"/\1/g')
aws_region=$(grep -E ' *region *=' terraform/terraform.tfvars | sed -E 's/ *aws_region *= *"(.*)"/\1/g')

aws route53 delete-hosted-zone \
  --profile "$aws_profile" \
  --name "$route53_zone_fqdn" \
  --caller-reference "$route53_caller_reference" > tmp/create-hosted-zone.out
```
