output "instance_ip" {
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
  description = "External IP of the VM"
}

output "bucket_name" {
  value       = google_storage_bucket.bucket.name
  description = "Created bucket name"
}
