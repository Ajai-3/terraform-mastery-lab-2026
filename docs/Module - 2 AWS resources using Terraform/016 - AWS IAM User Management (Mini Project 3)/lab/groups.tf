resource "aws_iam_group" "education" {
  name = "Education"
  path = "/groups/"
}

resource "aws_iam_group" "engneers" {
  name = "Engneers"
  path = "/groups/"
}

resource "aws_iam_group" "managers" {
  name = "Managers"
  path = "/groups/"
}

resource "aws_iam_group_membership" "education_members" {
  name = "education-group-membership"
  group = aws_iam_group.education.name

  users = [
    for user in aws_iam_user.users : user.name if user.tags.Department == "Education"
  ]
}

resource "aws_iam_group_membership" "managers_members" {
  name = "managers-group-membership"
  group = aws_iam_group.managers.name

  users = [
    for user in aws_iam_user.users : user.name if user.tags.Department == "Engneering"
  ]
}

resource "aws_iam_group_membership" "engneers_members" {
  name = "engneers-group-membership"
  group = aws_iam_group.engneers.name

  users = [
    for user in aws_iam_user.users : user.name if contains(keys(user.tags), "JobTitle") && can(regex("Manager|CEO", user.tags.JobTitle))
  ]
}