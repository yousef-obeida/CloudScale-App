variable "student_name" {
  type        = string
  description = "Your name for resource naming and tagging"
  default     = "Omar Elkaleh , Mohammed Eltabouli , Yousef Obeida"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy resources"
  default     = "East US"
}

variable "docker_image" {
  type        = string
  description = "The Docker image to pull from Docker Hub"
  default     = "yourdockerhubusername/cloudscale-app:v1"
}