variable "region" {
  default     = "us-west-1"
  description = "AWS region"
}

variable "db_password" {
  description = "RDS root user password"
  default = "cmpdev123"
  sensitive   = true
}

variable "access_key" {
}

variable "secret_key" {
}
