###########
## IAM
###########

resource "aws_iam_role" "ecs_autoscale_role" {
  name = "${local.app_name}-ecs_autoscale-role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "application-autoscaling.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale_role_attach" {
  role       = aws_iam_role.ecs_autoscale_role.name
  policy_arn = local.IAM_POLICY_ARN_AmazonEC2ContainerServiceAutoscaleRole
}

###########
## AutoScaling Target
###########

resource "aws_appautoscaling_target" "appautoscaling_ecs_frontend_target" {
  service_namespace = "ecs"

  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  role_arn = aws_iam_role.ecs_autoscale_role.arn

  min_capacity = local.min_capacity
  max_capacity = local.max_capacity
}

###########
## AutoScaling Target
###########

resource "aws_appautoscaling_policy" "appautoscaling_scale_up" {
  name              = "${local.app_name}-frontend-scale-up"
  service_namespace = aws_appautoscaling_target.appautoscaling_ecs_frontend_target.service_namespace

  resource_id        = aws_appautoscaling_target.appautoscaling_ecs_frontend_target.resource_id
  scalable_dimension = aws_appautoscaling_target.appautoscaling_ecs_frontend_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "appautoscaling_scale_down" {
  name              = "${local.app_name}-frontend-scale-down"
  service_namespace = aws_appautoscaling_target.appautoscaling_ecs_frontend_target.service_namespace

  resource_id        = aws_appautoscaling_target.appautoscaling_ecs_frontend_target.resource_id
  scalable_dimension = aws_appautoscaling_target.appautoscaling_ecs_frontend_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }
}

###########
## CloudWatch Metric Alarm
###########

resource "aws_cloudwatch_metric_alarm" "alarm_cpu_high_70" {
  alarm_name = "${local.app_name}-frontend-cpu-utilization-high-70"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"

  threshold = local.scale_up_threshold

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.frontend.name
  }

  alarm_actions = [aws_appautoscaling_policy.appautoscaling_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "alarm_cpu_low_25" {
  alarm_name = "${local.app_name}-frontend-cpu-utilization-low-25"

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"

  threshold = local.scale_down_threshold

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.frontend.name
  }

  alarm_actions = [aws_appautoscaling_policy.appautoscaling_scale_down.arn]
}
