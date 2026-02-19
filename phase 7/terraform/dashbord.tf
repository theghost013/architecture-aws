resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "StudentApp-Advanced-Monitoring"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0, "y": 0, "width": 8, "height": 6,
      "properties": {
        "metrics": [ [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${aws_autoscaling_group.app_asg.name}" ] ],
        "period": 300, "stat": "Average", "region": "us-east-1",
        "title": "CPU (%) - Moyenne Groupe"
      }
    },
    {
      "type": "metric",
      "x": 8, "y": 0, "width": 8, "height": 6,
      "properties": {
        "metrics": [ [ "CWAgent", "mem_used_percent", "AutoScalingGroupName", "${aws_autoscaling_group.app_asg.name}" ] ],
        "period": 300, "stat": "Average", "region": "us-east-1",
        "title": "RAM (%) - Métrique Agent"
      }
    },
    {
      "type": "metric",
      "x": 16, "y": 0, "width": 8, "height": 6,
      "properties": {
        "metrics": [ [ "CWAgent", "disk_used_percent", "AutoScalingGroupName", "${aws_autoscaling_group.app_asg.name}", "path", "/" ] ],
        "period": 300, "stat": "Average", "region": "us-east-1",
        "title": "Disque (%) - Occupation"
      }
    },
    {
      "type": "metric",
      "x": 0, "y": 6, "width": 12, "height": 6,
      "properties": {
        "metrics": [ [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_lb.web_alb.arn_suffix}" ] ],
        "period": 300, "stat": "Sum", "region": "us-east-1",
        "title": "Trafic (Requêtes totales ALB)"
      }
    },
    {
      "type": "metric",
      "x": 12, "y": 6, "width": 12, "height": 6,
      "properties": {
        "metrics": [ [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "${aws_lb_target_group.web_tg.arn_suffix}", "LoadBalancer", "${aws_lb.web_alb.arn_suffix}" ] ],
        "period": 300, "stat": "Average", "region": "us-east-1",
        "title": "Santé (Instances opérationnelles)"
      }
    }
  ]
}
EOF
}