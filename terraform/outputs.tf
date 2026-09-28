output "bastion_ip" {
  description = "Public IP for SSH access"
  value       = yandex_compute_instance.vm["bastion"].network_interface[0].nat_ip_address
}

output "alb_ip" {
  description = "Public IP of the website load balancer"
  value       = yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "vm_addresses" {
  description = "VM names and addresses"
  value = {
    for name, vm in yandex_compute_instance.vm : name => {
      fqdn       = vm.fqdn
      private_ip = vm.network_interface[0].ip_address
      public_ip  = vm.network_interface[0].nat_ip_address
    }
  }
}

output "snapshot_schedule_id" {
  value = yandex_compute_snapshot_schedule.daily.id
}
