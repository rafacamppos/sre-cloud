resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "Minhas API's"
  description = "AWS Rest API"
  endpoint_configuration {
   types = ["REGIONAL"]
  }
}

resource "aws_iam_role" "lambda_exec" {
   name = "lambda_exec"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_lambda_function" "entrada_fila" {
  function_name = "ServerlessExample"

   # The bucket name as created earlier with "aws s3api create-bucket"
   s3_bucket = "nodeless-dev-serverlessdeploymentbucket-1elr2w1wakl3j"
   s3_key    = "nodeless.zip"

   # "main" is the filename within the zip file (main.js) and "handler"
   # is the name of the property under which the handler function was
   # exported in that file.
   handler = "lambda1.handler"


   role = aws_iam_role.lambda_exec.arn
  runtime = "nodejs12.x"
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_method" "POSTMSG" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
   resource_id = aws_api_gateway_method.POSTMSG.resource_id
   http_method = aws_api_gateway_method.POSTMSG.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.entrada_fila.invoke_arn
}
