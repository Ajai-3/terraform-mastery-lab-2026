locals {
  formatted_project_name = lower(replace(var.project_name, " ", "-"))
  new_tag                = merge(var.default_tags, var.environment_tags)
  formatted_bucket_name = replace(replace(
    substr(lower(var.bucket_name), 3, 63)
    , " ", ""
  ), "!", "")

  port_list = split(",", replace(var.allowed_ports, " ", ""))

  sg_rule = [for port in local.port_list :
    {
      name        = "port-${port}",
      port        = port,
      description = "Allow traffic on port ${port}"
  }]

  instance_size = lookup(var.instance_size, var.environment, "t2.micro")
}

resource "aws_s3_bucket" "name" {
  bucket = local.formatted_bucket_name

  tags = local.new_tag
}

# resource 