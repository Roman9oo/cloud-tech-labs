
###
# 1. SNS Topic та Email-підписка
###
resource "aws_sns_topic" "notify_me" {
  name = "notify-me"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.notify_me.arn
  protocol  = "email"
  endpoint  = "roman.bolonnyi.ri.2023@lpnu.ua"
}

###
# 2. CloudWatch Alarm для помилок Lambda
###
resource "aws_cloudwatch_metric_alarm" "lambda_errors_alarm" {
  alarm_name          = "LambdaErrorAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when lambda errors > 1 in 1 minute"
  alarm_actions       = [aws_sns_topic.notify_me.arn]
  dimensions = {
    FunctionName = "get-all-courses" # Назва твоєї Lambda
  }
}

###
# 3. CloudWatch Billing Alarm (спрацює при > $1)
###

resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "BillingAlarmOver1USD"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600
  statistic           = "Maximum"
  threshold           = 1
  alarm_description   = "Billing exceeds $1"
  alarm_actions       = [aws_sns_topic.notify_me.arn]
  dimensions = {
    Currency = "USD"
  }
}
