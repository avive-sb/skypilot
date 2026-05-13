variable "zone" {
  type    = string
  default = "us-west1-a"
}

locals {
  date = formatdate("YYMMDD", timestamp())
}

source "googlecompute" "gpu-ubuntu" {
  image_name          = "skypilot-gcp-gpu-ubuntu-${local.date}"
  project_id          = "credible-flag-399512"
  source_image_family = "ubuntu-2204-lts"
  zone                = var.zone
  image_description   = "SkyPilot custom image for launching GCP GPU instances."
  tags                = ["packer", "gpu", "ubuntu"]
  disk_size           = 50
  machine_type        = "g2-standard-4"
  accelerator_type    = "projects/credible-flag-399512/zones/${var.zone}/acceleratorTypes/nvidia-l4"
  accelerator_count   = 1
  on_host_maintenance = "TERMINATE"
  ssh_username        = "gcpuser"
}

build {
  name    = "gcp-gpu-ubuntu-build"
  sources = ["sources.googlecompute.gpu-ubuntu"]
  provisioner "shell" {
    script = "./provisioners/docker.sh"
  }
  provisioner "shell" {
    script = "./provisioners/cuda.sh"
  }
  provisioner "shell" {
    script = "./provisioners/nvidia-container-toolkit.sh"
  }
  provisioner "shell" {
    environment_vars = [
      "CLOUD=gcp",
    ]
    script = "./provisioners/skypilot.sh"
  }
  provisioner "shell" {
    script = "./provisioners/user-toolkit.sh"
  }
}
