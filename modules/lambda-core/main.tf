# IAM role for Lambda to allow execution with necessary trust policy
resource "aws_iam_role" "lambda_exec" {
  name = "findora-core-lambda-role"
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

# Attach AWS basic execution policy to the Lambda role for logging, etc.
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Core Lambda function that runs the backend logic for the API
resource "aws_lambda_function" "core" {
  function_name    = "findora-core"
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

# Create an HTTP API Gateway to expose the Lambda function via RESTful HTTP
resource "aws_apigatewayv2_api" "http_api" {
  name          = "findora-api"
  protocol_type = "HTTP"
}

# Integrate API Gateway with the Lambda function using AWS_PROXY for full request/response handling
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.core.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Route all requests (ANY method, any path) through the API Gateway to the Lambda integration
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}


# Default stage for the API, auto-deployed with each change
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# Permission for API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.core.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# Custom domain mapping for API Gateway (e.g. api.findora.nl) with TLS certificate
resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = "api.${var.domain}"
  domain_name_configuration {
    certificate_arn = var.api_cert_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# Map the custom domain and default stage to the API Gateway
resource "aws_apigatewayv2_api_mapping" "api_map" {
  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.api.id
  stage       = aws_apigatewayv2_stage.default_stage.name
}
