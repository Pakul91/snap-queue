navigate to the terraform directory and run:

```
> terraform init -backend-config config/<env>
> terraform plan -var-file=vars/<env>.tfvars --out=.tfplan
> terraform apply .tfplan
```

To destroy the infrastructure:

```
> terraform -destroy -var-file=vars/<env>.tfvars

```
