# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec" {
  name = "${replace(var.domain, ".", "-")}-core-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach basic execution role for logging
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "core" {
  function_name    = "${replace(var.domain, ".", "-")}-core"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  filename         = var.lambda_package_path
  source_code_hash = filebase64sha256(var.lambda_package_path)
  timeout          = 10

  environment {
    variables = {
      OPENAI_API_KEY = var.openai_api_key
    }
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "findora-api"
  protocol_type = "HTTP"
}

# Lambda Integration for API Gateway
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.core.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# API Route
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "apigw_logs" {
  name              = "/aws/apigateway/${replace(var.domain, ".", "-")}-api"
  retention_in_days = 14
}

# API Stage with Access Logs
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_logs.arn
    format          = "requestId: $context.requestId, routeKey: $context.routeKey, status: $context.status, integrationStatus: $context.integrationStatus"
  }
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.core.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# Custom Domain for API Gateway
resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = "api.${var.domain}"

  domain_name_configuration {
    certificate_arn = var.api_cert_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# API Mapping to custom domain
resource "aws_apigatewayv2_api_mapping" "api_map" {
  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.api.id
  stage       = aws_apigatewayv2_stage.default_stage.name
}
