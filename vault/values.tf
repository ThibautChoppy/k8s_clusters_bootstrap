variable "user_admin_passwd" {
  sensitive = true
  type = string
  default = "adminPassword"
}

variable "SA_TOKEN" {
  type = string
  default = ""
}

variable "SA_ADDR" {
  type = string
  default = ""
}