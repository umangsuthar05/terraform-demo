data "aws_iam_policy_document" "ec2_role_policy_data" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "asg_ec2_iam_role" {
  name               = "${var.stack_name}-ec2-role-ecs"
  assume_role_policy = data.aws_iam_policy_document.ec2_role_policy_data.json
}

resource "aws_iam_instance_profile" "asg_ec2_instance_profile" {
  name = "${var.stack_name}-ec2-role-ecs"
  role = aws_iam_role.asg_ec2_iam_role.id
  provisioner "local-exec" {
    command = "sleep 60"
  }
}