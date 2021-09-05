data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "github_release" "romira_s_service_manage_bot_release" {
  owner       = "Romira915"
  repository  = "romira-s_service_manage_bot"
  retrieve_by = "latest"
}

data "http" "discord_bot_client_latest_url" {
  url = data.github_release.romira_s_service_manage_bot_release.asserts_url

  request_headers = {
    Accept = "application/json"
  }
}
