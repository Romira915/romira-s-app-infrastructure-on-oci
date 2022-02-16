output "name-of-first-availability-domain" {
  value = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

output "app-instance-public-ip" {
  value = oci_core_instance.app_instance.public_ip
}

output "cloud-instance-public-ip" {
  value = oci_core_instance.raycloud_instance.public_ip
}

output "discord_bot_asset_url" {
  value = jsondecode(data.http.discord_bot_client_latest_url.body)[0]["browser_download_url"]
}
