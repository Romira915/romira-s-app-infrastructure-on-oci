variable "compartment_id" {
  description = "OCID from your tenancy page"
  type        = string
  sensitive   = true
}
variable "region" {
  description = "region where you have OCI tenancy"
  type        = string
  default     = "ap-tokyo-1"
}

variable "ssh_public_key_path" {
  description = "ssh public key path"
  type        = string
}

variable "ssh_private_key_path" {
  description = "ssh private key path"
  type        = string
}

variable "image_id" {
  description = "image id"
  type        = string
  default     = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaaymes4ncljbztzxnf5bchyc7ag4oumbh5nwxt2wrbxfyycdngc6yq"
}

variable "discord_bot_client_filename" {
  type    = string
  default = "discord_bot_client"
}

variable "app_instance_data_path" {
  type    = string
  default = "app_instance_data"
}

variable "discord_bot_dirname" {
  type    = string
  default = "discord_bot_for_mgpf"
}

variable "app_instance_ssh_port" {
  type    = number
  default = 22
}

variable "azure_username" {
  type      = string
  sensitive = true
}

variable "azure_password" {
  type      = string
  sensitive = true
}
