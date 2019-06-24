resource "aws_ecs_service" "node" {
  name            = "hello-world"
  cluster         = aws_ecs_cluster.demo.id
  task_definition = aws_ecs_task_definition.node.arn
  desired_count   = 4
  iam_role        = aws_iam_role.ecs-service-role.arn
  depends_on      = [aws_iam_role_policy_attachment.ecs-service-attach]

  load_balancer {
    target_group_arn = aws_alb_target_group.node.id
    container_name   = "hello-world"
    container_port   = "3000"
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_task_definition" "node" {
  family = "node"

  container_definitions = <<EOF
[
  {
    "portMappings": [
      {
        "hostPort": 0,
        "protocol": "tcp",
        "containerPort": 3000
      }
    ],
    "cpu": 256,
    "memory": 300,
    "image": "arshak808/hello-world:latest",
    "essential": true,
    "name": "hello-world",
    "logConfiguration": {
    "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs-demo/node",
        "awslogs-region": "eu-west-2",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOF

}

resource "aws_cloudwatch_log_group" "node" {
  name = "/ecs-demo/node"
}
