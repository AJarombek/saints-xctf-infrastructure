variable "db_client_access_cidr" {
  description = "CIDR block allowed to access the database client. Use '0.0.0.0/0' to allow from anywhere."
  type        = string
  default     = "0.0.0.0/0"
}

