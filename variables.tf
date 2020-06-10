variable "monk_ami" {
  type = string
  default = ""
}

variable "monk_state_bucket" {
  type = string
  default = ""
}

variable "monk_state_path" {
  type = string
  default = "dev/monk/states/"
}

variable "monk_state_bucket_reg" {
  type = string
  default = "us-east-1"
}

variable "work_machine_ip" {
  type = string
  default = ""
}

variable "ssh_public_key_path" {
  type = string
  default = ""
}