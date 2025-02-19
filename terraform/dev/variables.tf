variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "owner" {
  description = "Resource owner tag"
  type        = string
  default     = "DevOps Team"
}

variable "repo_tag" {
  description = "GitHub repository tag"
  type        = string
  default     = "https://github.com/pogdaniel/InfraChallenge"
}
