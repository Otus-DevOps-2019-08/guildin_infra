variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
}
variable private_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable zone {
  description = "zone to deploy in"
  # Значение по умолчанию
  default = "europe-west1-b"
}
variable another_user {
  description = "appuser for *-task 1"
  default     = "appuser1"
}
variable another_pubkey {
  description = "appuser for *-task 1"
  default     = "~/.ssh/appuser1.pub"
}
variable another_privkey {
  description = "appuser for *-task 1"
  default     = "~/.ssh/appuser1"
}
