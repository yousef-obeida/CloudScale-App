variable "student_name" {
  type        = string
  description = "Your name for resource naming and tagging"
  default     = "Omar-Mohammed-Yousef-v6"
} 

variable "location" {
  type        = string
  description = "The Azure region to deploy resources"
  default     = "switzerlandnorth"
}

variable "docker_image" {
  type        = string
  description = "The Docker image to pull from Docker Hub"  
  default     = "yousefobeida/cloudscale-app:v1"
}