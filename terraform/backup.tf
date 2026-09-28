resource "yandex_compute_snapshot_schedule" "daily" {
  name             = "diplom-daily-backup"
  description      = "Daily snapshots of all VM disks, retained for one week"
  retention_period = "168h"

  schedule_policy {
    expression = "0 1 * * *"
  }

  snapshot_spec {
    description = "Automatic daily diploma backup"
    labels = {
      project = "sys-diplom"
    }
  }

  disk_ids = [
    for vm in yandex_compute_instance.vm : vm.boot_disk[0].disk_id
  ]
}
