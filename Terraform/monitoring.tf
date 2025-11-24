# يجب استبدال القيمة الافتراضية هنا بالـ ID الفعلي لسيرفر الباك إند
variable "backend_instance_id" {
  description = "The EC2 Instance ID of the Laravel backend machine."
  type        = string
  default     = "i-0abcdef1234567890"  
}

# 1. Create SNS Topic 
resource "aws_sns_topic" "cpu_alert_topic" {
  name = "backend-cpu-alert-topic"
}

# 2. Sub SNS Topic Via Email
resource "aws_sns_topic_subscription" "cpu_alert_email_subscription" {
  topic_arn = aws_sns_topic.cpu_alert_topic.arn
  protocol  = "email"
  endpoint  = "anaa7med3zz@gmail.com"
}

# 3. Create CloudWatch Metric Alarm 
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "Backend-High-CPU-Utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2" # Repeat Mins
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60" # Metric
  statistic           = "Average"
  threshold           = "50" # Max (50%)
  
  # Connect SNS when change it to ALARM
  alarm_actions       = [aws_sns_topic.cpu_alert_topic.arn]
  
  # Soecify the server Instance ID
  dimensions = {
    InstanceId = var.backend_instance_id
  }
  
  alarm_description   = "Triggers when the average CPU Utilization exceeds 50% for 2 consecutive periods (2 minutes)."
}
