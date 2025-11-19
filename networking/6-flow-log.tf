resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/vpc/flowlogs"
  retention_in_days = 7
}

resource "aws_iam_role" "flowlog_role" {
  name = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "flowlog_policy" {
  role = aws_iam_role.flowlog_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_flow_log" "this" {
  vpc_id          = aws_vpc.this.id
  iam_role_arn    = aws_iam_role.flowlog_role.arn
  log_destination = aws_cloudwatch_log_group.this.arn
  traffic_type    = "ALL"
}
