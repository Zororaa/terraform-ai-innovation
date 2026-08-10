output "module_path" {
  value = path.module
}

output "sql_source_path" {
  value = "${path.module}/../../sql/${var.env}"
}