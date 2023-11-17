locals {  
  name            = ""
  cluster_version = ""
  region          = ""
  vpc_id     = ""
  subnet_ids = ["",""]
  tags = {
    Owners  = ""
    Environment = ""
  }
}
################################################################################
module "eks" {
  source = ""
  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  aws_auth_users = [
    {
      userarn  = ""
      username = ""
      groups   = ["system:masters"]
    }
  ]
  aws_auth_accounts = [
    ""
  ]
  manage_aws_auth_configmap = true
  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }
  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  self_managed_node_group_defaults = {
    create_security_group = false
    # enable discovery of autoscaling groups by cluster-autoscaler
    autoscaling_group_tags = {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/${local.name}" : "owned",
    }
  }
  self_managed_node_groups = {
    on-demand = {
      name            = "${local.name}-self-mng"
      use_name_prefix = false
      subnet_ids = ["subnet-02e404d40603b162e","subnet-0908a25355fa7dbf9"]
      min_size     = 2
      max_size     = 3
      desired_size = 2
      ami_id               = data.aws_ami.eks_default.id
      bootstrap_extra_args = "--kubelet-extra-args '--max-pods=110'"
      pre_bootstrap_user_data = <<-EOT
      export CONTAINER_RUNTIME="containerd"
      export USE_MAX_PODS=false
      EOT
      post_bootstrap_user_data = <<-EOT
      echo "you are free little kubelet!"
      EOT
      instance_type = "t3.xlarge"
      launch_template_name            = "self-managed-${local.name}"
      launch_template_use_name_prefix = true
      launch_template_description     = "Self managed node group ${local.name} launch template"
      ebs_optimized          = true
      vpc_security_group_ids = [aws_security_group.additional.id]
      enable_monitoring      = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 75
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = false
#            kms_key_id            = aws_kms_key.ebs.arn
            delete_on_termination = true
          }
        }
      }
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }
      create_iam_role          = true
      iam_role_name            = "self-managed-node-group-${local.name}"
      iam_role_use_name_prefix = false
      iam_role_description     = "Self managed node group ${local.name}"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]
      create_security_group          = true
      security_group_name            = "self-managed-node-group-${local.name}"
      security_group_use_name_prefix = false
      security_group_description     = "Self managed node group ${local.name} security group"
      security_group_rules = {
        phoneOut = {
          description = "Hello CloudFlare"
          protocol    = "udp"
          from_port   = 53
          to_port     = 53
          type        = "egress"
          cidr_blocks = ["1.1.1.1/32"]
        }
        phoneHome = {
          description                   = "Hello cluster"
          protocol                      = "udp"
          from_port                     = 53
          to_port                       = 53
          type                          = "egress"
          source_cluster_security_group = true # bit of reflection lookup
        }
      }
      security_group_tags = {
        Purpose = "Protector of the kubelet"
      }
      timeouts = {
        create = "80m"
        update = "80m"
        delete = "80m"
      }
      tags = {
        ExtraTag = "Self managed node group ${local.name}"
      }
    }
  }
  tags = local.tags
}
################################################################################
# Supporting Resources
################################################################################
resource "aws_security_group" "additional" {
  name_prefix = "${local.name}-additional"
  vpc_id     = local.vpc_id
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.20.0.0/16"
    ]
  }
  tags = local.tags
}
data "aws_caller_identity" "current" {
  #account_id = ""
}
data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v*"]
  }
}
data "aws_ami" "eks_default_bottlerocket" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${local.cluster_version}-x86_64-*"]
  }
}
resource "tls_private_key" "this" {
  algorithm = "RSA"
}
resource "aws_key_pair" "this" {
  key_name   = local.name
  public_key = tls_private_key.this.public_key_openssh
}


