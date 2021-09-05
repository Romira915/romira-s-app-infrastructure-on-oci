resource "oci_core_instance" "app_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E2.1.Micro"
  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  display_name = "app-instance"
  defined_tags = {
    "Romira-s-Tags.Always-Free" = "true"
  }
  metadata = {
    "ssh_authorized_keys" = file(var.ssh_public_key_path)
    "user_data" = base64encode(join("\n", [
      "#cloud-config",
      yamlencode({
        timezone : "Asia/Tokyo",
        package_update : true,
        package_upgrade : true,
        packages : [
          "wget",
          "vim",
          "iptables-persistent",
        ],
        write_files : [
          {
            path : "/etc/systemd/system/discord-bot-mgpf.service",
            content : file("${var.app_instance_data_path}/discord-bot-mgpf.service"),
          },
        ],
        runcmd : [
          ["systemctl", "enable", "discord-bot-mgpf.service"],
          ["systemctl", "start", "discord-bot-mgpf.service"],
          format("/bin/sed -i -e \"s/#Port 22/Port %d/\" /etc/ssh/sshd_config", var.app_instance_ssh_port),
          format("/bin/sed -i -e \"s/-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT/-A INPUT -p tcp -m state --state NEW -m tcp --dport %d -j ACCEPT/\" /etc/iptables/rules.v4", var.app_instance_ssh_port),
          ["systemctl", "restart", "ssh"],
          ["systemctl", "restart", "sshd"],
          "iptables-restore < /etc/iptables/rules.v4",
        ],
      }),
      ]
    ))
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = self.public_ip
    port        = var.app_instance_ssh_port
    timeout     = "10m"
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.bin/"
    ]
  }
  provisioner "file" {
    source      = var.app_instance_data_path
    destination = "~/"
  }
  provisioner "remote-exec" {
    inline = [
      "mv ~/${var.app_instance_data_path}/${var.discord_bot_dirname} ~/.bin/",
      "chmod 0755 ~/.bin/${var.discord_bot_dirname}/${var.discord_bot_client_filename}"
    ]
  }

  preserve_boot_volume = false
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.public_app_subnet.id
  }

  depends_on = [
    null_resource.download_discord_bot_client
  ]
}

resource "null_resource" "download_discord_bot_client" {
  # triggers = {
  #   timestamp = timestamp()
  # }

  provisioner "local-exec" {
    command = fileexists("$path") ? "" : "wget $url -O $path"

    environment = {
      url  = jsondecode(data.http.discord_bot_client_latest_url.body)[0]["browser_download_url"]
      path = format("%s/%s/%s", var.app_instance_data_path, var.discord_bot_dirname, var.discord_bot_client_filename)
    }
  }
}
