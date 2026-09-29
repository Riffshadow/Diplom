variable "image_id" {
  description = "Общий образ Ubuntu 24.04 для всех ВМ"
  type        = string
  default     = "fd8ee8il5b8tk8oggcs0"
}

variable "ssh_public_key_path" {
  description = "Путь к публичному SSH-ключу"
  type        = string
  default     = "~/.ssh/diplom_ed25519.pub"
}

variable "preemptible" {
  description = "Использовать прерываемые виртуальные машины"
  type        = bool
  default     = false
}
