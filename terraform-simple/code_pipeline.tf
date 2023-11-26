###########
## CodeStarConnection
###########

# 後で修正
resource "aws_codestarconnections_connection" "github" {
  name          = "${local.app_name}-github-connection"
  provider_type = "GitHub"
}

###########
## CodePipeline IAM Role
###########

resource "aws_iam_role" "codepipeline_role" {
  name = "${local.app_name}-codepipeline-role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "codepipeline.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_policy" "pipeline_service" {
  policy = file("${path.module}/json/code_pipeline/AWSCodePipelineServiceRole.json")
}

resource "aws_iam_role_policy_attachment" "attach_pipeline_service" {
  policy_arn = aws_iam_policy.pipeline_service.arn
  role       = aws_iam_role.codepipeline_role.name
}

###########
## S3 Artifact Store
###########

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${local.app_name}-codepipeline-artifact"
}

# 以下のErrorのため、とりあえず作成しない
#  Error: error creating S3 bucket ACL for ecs-spa-codepipeline-artifact: AccessControlListNotSupported: The bucket does not allow ACLs
# │       status code: 400, request id: E8DZ97E1VCGNZN5K, host id: VVIGnvUZrcmII/yHCRaATlR1wovmw0+Yhm6nABLGTvSetQv6j0JP+NZ+GN66PeIhPGKeTJAX3tE=
# │
# │   with aws_s3_bucket_acl.codepipeline_bucket,
# │   on code_pipeline.tf line 50, in resource "aws_s3_bucket_acl" "codepipeline_bucket":
# │   50: resource "aws_s3_bucket_acl" "codepipeline_bucket" {
# resource "aws_s3_bucket_acl" "codepipeline_bucket" {
#   bucket = aws_s3_bucket.codepipeline_bucket.id
#   acl    = "private"
# }

###########
## CodeBuild project
###########

resource "aws_iam_role" "build_role" {
  name = "${local.app_name}-codebuild-role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "codebuild.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

# 後で修正
resource "aws_iam_policy" "build_base" {
  name = "${local.app_name}-CodeBuildBasePolicy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Resource" : ["*"],
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
        },
        {
          "Effect" : "Allow",
          "Resource" : [
            "${aws_s3_bucket.codepipeline_bucket.arn}/*"
          ],
          "Action" : [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases",
            "codebuild:BatchPutCodeCoverages"
          ],
          "Resource" : [
            "arn:aws:codebuild:ap-northeast-1:${data.aws_caller_identity.current.account_id}:report-group/*"
          ]
        }
      ]
    }
  )
}

# 後で修正
resource "aws_iam_policy" "build_secret" {
  name = "${local.app_name}-CodeBuildSecretPolicy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameters"
          ],
          "Resource" : "arn:aws:ssm:ap-northeast-1:${data.aws_caller_identity.current.account_id}:parameter/CodeBuild/*",
        }
      ]
    }
  )
}

# 後で修正(おそらく、EC2上に作成されるCodeBuildに必要)
resource "aws_iam_policy" "build_vpc" {
  name = "${local.app_name}-CodeBuildVPCPolicy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeDhcpOptions",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeVpcs"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterfacePermission"
          ],
          "Resource" : "arn:aws:ec2:ap-northeast-1:${data.aws_caller_identity.current.account_id}:network-interface/*",
          "Condition" : {
            "StringEquals" : {
              "ec2:Subnet" : [
                "${aws_subnet.private[0].arn}",
                "${aws_subnet.private[1].arn}",
                "${aws_subnet.private[2].arn}",
              ],
              "ec2:AuthorizedService" : "codebuild.amazonaws.com"
            }
          }
        }
      ]
    }
  )
}

# 後で修正
resource "aws_iam_policy" "build_kms" {
  name = "${local.app_name}-CodeBuildKMSPolicy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "kms:ListKeys",
            "kms:ListAliases",
            "kms:DescribeKey",
            "kms:ListKeyPolicies",
            "kms:GetKeyPolicy",
            "kms:GetKeyRotationStatus",
            "kms:GetPublicKey",
            "kms:ListResourceTags",
            "tag:GetResources",
            "iam:ListUsers",
            "iam:ListRoles"
          ],
          "Resource" : "*",
          "Effect" : "Allow"
        }
      ]
    }
  )
}

# 後で修正
resource "aws_iam_policy" "build_ecr_put" {
  name = "${local.app_name}-CodeBuildECRPutPolicy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "ecr:BatchGetImage",
            "ecr:CompleteLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:InitiateLayerUpload",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

# 後でmodule化して冗長性を解消
resource "aws_iam_role_policy_attachment" "build_base_attach" {
  policy_arn = aws_iam_policy.build_base.arn
  role       = aws_iam_role.build_role.name
}

resource "aws_iam_role_policy_attachment" "build_secret_attach" {
  policy_arn = aws_iam_policy.build_secret.arn
  role       = aws_iam_role.build_role.name
}

resource "aws_iam_role_policy_attachment" "build_vpc_attach" {
  policy_arn = aws_iam_policy.build_vpc.arn
  role       = aws_iam_role.build_role.name
}

resource "aws_iam_role_policy_attachment" "build_kms_attach" {
  policy_arn = aws_iam_policy.build_kms.arn
  role       = aws_iam_role.build_role.name
}

resource "aws_iam_role_policy_attachment" "build_ecr_read" {
  policy_arn = local.IAM_POLICY_ARN_AmazonEC2ContainerRegistryReadOnly
  role       = aws_iam_role.build_role.name
}

resource "aws_iam_role_policy_attachment" "build_ecr_put" {
  policy_arn = aws_iam_policy.build_ecr_put.arn
  role       = aws_iam_role.build_role.name
}

resource "aws_iam_role_policy_attachment" "build_ssm_read" {
  policy_arn = local.IMA_POLICY_ARN_AmazonSSMReadOnlyAccess
  role       = aws_iam_role.build_role.name
}

# codebuildはprivate subnetに配置

resource "aws_codebuild_project" "build" {
  name         = "${local.app_name}-buildproject"
  service_role = aws_iam_role.build_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    # MySQL
    environment_variable {
      name  = "DB_HOST"
      value = aws_ssm_parameter.db_url.name
      type  = "PARAMETER_STORE"
    }
    environment_variable {
      name  = "DB_DATABASE"
      value = data.aws_ssm_parameter.database_name.name
      type  = "PARAMETER_STORE"
    }
    environment_variable {
      name  = "DB_USERNAME"
      value = data.aws_ssm_parameter.database_user.name
      type  = "PARAMETER_STORE"
    }
    environment_variable {
      name  = "DB_PASSWORD"
      value = data.aws_ssm_parameter.database_password.name
      type  = "PARAMETER_STORE"
    }
    # Laravel
    environment_variable {
      name  = "APP_ENV"
      value = local.app_env_codebuild
    }
    environment_variable {
      name  = "APP_DEBUG"
      value = local.app_debug_codebuild
    }
    environment_variable {
      name  = "APP_KEY"
      value = data.aws_ssm_parameter.app_key.name
    }
  }
  vpc_config {
    security_group_ids = [aws_security_group.app.id]
    subnets            = [for subnet in aws_subnet.private : subnet.id]
    vpc_id             = aws_vpc.this.id
  }
  source {
    type = "CODEPIPELINE"
  }
}

###########
## CodePipeline
###########

resource "aws_codepipeline" "pipeline" {
  name     = "${local.app_name}-pipeline-deploy"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      category         = "Source"
      name             = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = 1
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn = aws_codestarconnections_connection.github.arn
        # 後で修正(テスト)
        FullRepositoryId = "yoshio464/laravel-react-todo-app"
        BranchName       = "master"
      }
    }
  }

  stage {
    name = "Build"
    action {
      category         = "Build"
      name             = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      category        = "Deploy"
      name            = "frontend-deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]
      configuration = {
        FileName    = "frontend_imagedefinitions.json"
        ClusterName = aws_ecs_cluster.this.name
        ServiceName = aws_ecs_service.frontend.name
      }
    }

    action {
      category        = "Deploy"
      name            = "backend-deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]
      configuration = {
        FileName    = "backend_imagedefinitions.json"
        ClusterName = aws_ecs_cluster.this.name
        ServiceName = aws_ecs_service.backend.name
      }
    }
  }
}
