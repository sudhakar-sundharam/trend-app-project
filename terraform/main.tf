provider "aws" {
  region = "ap-southeast-2"
}

# Use Default VPC - SCP blocks new VPC / SG creation
variable "vpc_id" {
  default = "vpc-0bcf3dac85e4a680e"
}
variable "subnet_id" {
  default = "subnet-0b1eb60cc3f2ea682"
}
variable "ami_id" {
  default = "ami-0231039d2b80be3ce"
}
variable "sg_id" {
  default = "sg-0c28a616c854562ee"
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "trend-app-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_admin" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "trend-app-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 with Jenkins
resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y openjdk-17-jre docker.io git curl
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              apt update -y
              apt install -y jenkins
              systemctl start jenkins
              systemctl enable jenkins
              EOF

  tags = { Name = "trend-app-jenkins" }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
output "vpc_id" {
  value = var.vpc_id
}