locals {
  all_locations       = concat(var.user_location, var.default_locations)
  all_unique_location = toset(local.all_locations)

  positive_cost = [for cost in var.monthly_cost : abs(cost)]
  max_cost      = max(local.positive_cost...)
  min_cost      = min(local.positive_cost...)
  total_cost    = sum(local.positive_cost)
  avg_const     = local.total_cost / length(local.positive_cost)

  current_time = timestamp()
  current_timestamp = timestamp()
  format1 = formatdate("yyyMMdd", local.current_timestamp)
  format2 = formatdate("YYYY-MM-DD", local.current_time)
}