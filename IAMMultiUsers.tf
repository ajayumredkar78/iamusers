# Define a list of users to create
locals {
  users = ["guddupandit", "bablu", "dimpy"] # Add your list of users here
}

# Create IAM Users
resource "aws_iam_user" "user" {
  for_each = toset(local.users) # List of users to create
  name     = each.key
  path     = "/"
}

# Create IAM Roles
resource "aws_iam_role" "role" {
  for_each = toset(["AdminAccess","Ec2Access"]) # List of roles to create
  name     = each.key
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach Policies to Roles
resource "aws_iam_role_policy_attachment" "policy_attach" {
  for_each = {
    for role, policy in {
      "AdminAccess" = "arn:aws:iam::aws:policy/AdministratorAccess"
      "Ec2Access"   = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    } : role => policy
  }

  role       = aws_iam_role.role[each.key].name
  policy_arn = each.value
}

# Attach Policies to Users
resource "aws_iam_user_policy_attachment" "user_policy_attach" {
  for_each = {
    for user, policy in {
      "guddupandit" = "arn:aws:iam::aws:policy/AdministratorAccess"
      "bablu"       = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
      "dimpy"       = "arn:aws:iam::aws:policy/AdministratorAccess"
    } : user => policy
  }
  user       = aws_iam_user.user[each.key].name
  policy_arn = each.value
}
