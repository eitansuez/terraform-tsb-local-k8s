This repository is about bootstrapping [tsb-local-k8s](https://github.com/boeboe/tetrate-service-bridge-minikube) with terraform.

The idea is to provision a TSB training environment.  `tsb-local-k8s` can do this with a single VM.  This terraform script provisions and configures that VM on GCP.

## Prerequisites

- Install the terraform CLI
- For TSB image sync'ing, you should have your image sync username and API key ready.
- A GCP account and a target GCP project with a service account key

## Steps

Create a `terraform.tfvars` file and in it, specify your service account key json file name, and your TSB image sync credentials.

```terraform
credentials_filename = "~/.ssh/my-service-account-key.json"
tsb_image_sync_username = "john-doe"
tsb_image_sync_apikey = "0123456789abcedf0123456789abcdef01234567"
```

Initialize terraform:

```shell
terraform init
```

Apply the terraform:

```shell
terraform apply
```

You can either use the `gcloud` CLI to ssh to the VM using the `ubuntu` user.

```shell
gcloud compute ssh ubuntu@tsb-vm
```

Alternatively, an ssh key pair is created as part of the provisioning process.  You will find the script `ssh-to-gcp-vm.sh` in the `output/` subdirectory.

```shell
cd output
./ssh-to-gcp-vm.sh
```

Configuration of the VM is performed with [cloud-init](https://cloudinit.readthedocs.io/), which is asynchronous.  Wait a couple of minutes for that process to complete.

On the VM, you can check the status of cloud-init with `cloud-init status` and by tailing the cloud-init output logs at `/var/log/cloud-init-output.log`.

Once on the VM, navigate to the `tsb-local` subdirectory.

```shell
cd tsb-local
```

The remaining time-consuming steps for provisioning TSB are left up to you:

```shell
./repo.sh sync
```

And:

```shell
make up
```

