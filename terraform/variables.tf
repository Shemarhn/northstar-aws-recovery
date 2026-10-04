variable "region" {
  type    = string
  default = "us-east-1"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
  validation {
    condition     = contains(["t3.micro", "t3.small"], var.instance_type)
    error_message = "Use a small x86 lab instance."
  }
}
variable "alert_email" {
  type = string
}
variable "allow_bucket_destroy" {
  type        = bool
  default     = false
  description = "Set true only after exporting recovery evidence and backups."
}
