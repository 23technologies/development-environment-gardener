# development-environment-gardener

Terraform definitions to start a gardener development environment on throw-away virtual machines.

The provisioning script will leave you with two detached screens, one running gardener itself, the other running the dashboard. Each component is run in a loop to recover from crashes and errors.

The dashboard is running on port 8080 of your VM. Login to the dashboard with the token from testuser-token.

How to use this development environment is documented [in the gardener project](https://github.com/gardener/gardener/blob/master/docs/development/local_setup.md)

# create vm

terraform apply

# destroy vm

terraform destroy -target hcloud_server.dev


