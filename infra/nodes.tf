locals {
  image = {
    ubuntu_lts = "fd8ueg1g3ifoelgdaqhb"
  }

  resources = {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  templates_dir              = "${path.module}/templates"
  cloud_config_template      = "${local.templates_dir}/nodes-cloud-config.tftpl"
  ansible_inventory_template = "${local.templates_dir}/ansible-inventory.tftpl"
}

locals {
  metadata = {
    serial-port-enable = 1
    user-data = templatefile(
      local.cloud_config_template,
      {
        ssh_public_key = file("~/.ssh/id_rsa.pub")
      }
    )
  }
}

resource "yandex_compute_instance" "initial_controller" {
  name        = "initial-controller"
  platform_id = "standard-v1"

  resources {
    core_fraction = local.resources.core_fraction
    cores         = local.resources.cores
    memory        = local.resources.memory
  }

  boot_disk {
    initialize_params {
      image_id = local.image.ubuntu_lts
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.main.id
    nat       = true
  }

  metadata = local.metadata
}

resource "yandex_compute_instance" "controller_1" {
  name        = "controller-1"
  platform_id = "standard-v1"

  resources {
    core_fraction = local.resources.core_fraction
    cores         = local.resources.cores
    memory        = local.resources.memory
  }

  boot_disk {
    initialize_params {
      image_id = local.image.ubuntu_lts
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.main.id
    nat       = true
  }

  metadata = local.metadata
}

resource "yandex_compute_instance" "worker_1" {
  name        = "worker-1"
  platform_id = "standard-v1"

  resources {
    core_fraction = local.resources.core_fraction
    cores         = local.resources.cores
    memory        = local.resources.memory
  }

  boot_disk {
    initialize_params {
      image_id = local.image.ubuntu_lts
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.main.id
    nat       = true
  }

  metadata = local.metadata
}

output "ansible_inventory" {
  value = templatefile(local.ansible_inventory_template, {
    initial_controller = yandex_compute_instance.initial_controller.network_interface[0].nat_ip_address
    controllers        = [yandex_compute_instance.controller_1.network_interface[0].nat_ip_address]
    workers            = [yandex_compute_instance.worker_1.network_interface[0].nat_ip_address]
  })
}
