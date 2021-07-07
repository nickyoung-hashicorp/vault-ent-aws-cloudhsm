# Vault Enterprise AWS Module

This is a Terraform module for provisioning Vault Enterprise with [integrated
storage](https://www.vaultproject.io/docs/concepts/integrated-storage) on AWS.
This module defaults to setting up a cluster with 5 Vault nodes (as recommended
by the [Vault with Integrated Storage Reference
Architecture](https://learn.hashicorp.com/vault/operations/raft-reference-architecture)).

## About This Module
This module implements the [Vault with Integrated Storage Reference
Architecture](https://learn.hashicorp.com/vault/operations/raft-reference-architecture#node)
on AWS using the Enterprise version of Vault 1.7+.

## How to Use This Module

- Ensure your AWS credentials are [configured
  correctly](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
  and have permission to use the following AWS services:
    - Amazon VPC
    - AWS Identity & Access Management (IAM)
    - AWS Key Management System (KMS)
    - Amazon EC2
    - Amazon Elastic Load Balancing (ALB)
    - Amazon Certificate Manager (ACM)
    - Amazon Secrets Manager
    - AWS Systems Manager Session Manager (optional - used to connect to EC2
      instances with session manager using the AWS CLI)

- To deploy without an existing VPC, use the [example VPC](examples/aws-vpc)
  code to build out the pre-requisite environment. Ensure you are selecting a
  region that has at least three [AWS Availability
  Zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-availability-zones).

- To deploy into an existing VPC, ensure the following components exist and are
  routed to each other correctly:
  - Three public subnets
  - Three [NAT
    gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) (one in each public subnet)
  - Three private subnets (please make sure your private subnets are
    specifically tagged so you can identify them. The Vault module will use
    these tags to deploy the Vault servers into them.)

- Use the [example](examples/aws-secrets-manager-acm) code to create TLS certs
  and store them [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
  along with importing them into [AWS Certificate
  Manager](https://aws.amazon.com/certificate-manager/)

- Create a Terraform configuration that pulls in the Vault module and specifies
  values for the required variables:

```hcl
provider "aws" {
  region = "<your AWS region>"
}

module "vault-ent" {
  source               = "<filepath to cloned module directory>"
  friendly_name_prefix = "<prefix for tagging/naming AWS resources>"
  vpc_id               = "<VPC id you wish to deploy into>"
  # private subnet tags allow you to filter which subnets you will
  # deploy Vault into
  private_subnet_tags = {
    <Key> = "<Value>"
  }
  secrets_manager_arn   = "<AWS Secrets Manager ARN where TLS certs are stored>"
  leader_tls_servername = "<The shared DNS SAN of the TLS certs being used>"
  lb_certificate_arn    = "<The cert ARN to be used on the Vault LB listener>"
}
```

  - Run `terraform init` and `terraform apply`

  - You must
    [initialize](https://www.vaultproject.io/docs/commands/operator/init#operator-init)
    your Vault cluster after you create it. Begin by logging into your Vault
    cluster using one of the following methods:
      - Using [Session
        Manager](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/session-manager.html)
      - SSH (you must provide the optional SSH key pair through the `key_name`
        variable and set a value for the `allowed_inbound_cidrs_ssh` variable.
          - Please note this Vault cluster is not public-facing. If you want to
            use SSH from outside the VPC, you are required to establish your own
            connection to it (VPN, etc).

  - To initialize the Vault cluster, run the following commands:

```shell
# sudo -i
# vault operator init
```

  - This should return back the following output which includes the recovery
    keys and initial root token (omitted here):

```shell
...
Success! Vault is initialized
```

  - Please securely store the recovery keys and initial root token that Vault
    returns to you.
  - To check the status of your Vault cluster, export your Vault token and run
    the
    [list-peers](https://www.vaultproject.io/docs/commands/operator/raft#list-peers)
    command:

```shell
# export VAULT_TOKEN="<your Vault token>"
# vault operator raft list-peers
```

- Please note that Vault does not enable [dead server
  cleanup](https://www.vaultproject.io/docs/concepts/integrated-storage/autopilot#dead-server-cleanup)
  by default. You must enable this to avoid manually managing the Raft
  configuration every time there is a change in the Vault ASG. To enable dead
  server cleanup, run the following command:

 ```shell
# vault operator raft autopilot set-config \
    -cleanup-dead-servers=true \
    -dead-server-last-contact-threshold=10 \
    -min-quorum=3
 ```

- You can verify these settings after you apply them by running the following command:

```shell
# vault operator raft autopilot get-config
```

## License

This code is released under the Mozilla Public License 2.0. Please see
[LICENSE](LICENSE) for more details.