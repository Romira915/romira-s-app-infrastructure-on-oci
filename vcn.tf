resource "oci_core_vcn" "app_vcn" {
  display_name   = "app-vcn"
  compartment_id = var.compartment_id
  cidr_blocks    = ["172.16.0.0/20"]
  dns_label      = "app"

  defined_tags = {
    "Romira-s-Tags.Always-Free" = "true"
  }
}


resource "oci_core_internet_gateway" "internet_gateway_for_app" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.app_vcn.id

  enabled      = true
  display_name = "Internet Gateway app_vcn"

  defined_tags = {
    "Romira-s-Tags.Always-Free" = "true"
  }
}


resource "oci_core_route_table" "route_table_for_public_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.app_vcn.id

  display_name = "Route Table public subnet"
  route_rules {
    network_entity_id = oci_core_internet_gateway.internet_gateway_for_app.id
    destination       = "0.0.0.0/0"
  }

  defined_tags = {
    "Romira-s-Tags.Always-Free" = "true"
  }
}

resource "oci_core_security_list" "security_list_for_app" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.app_vcn.id

  display_name = "Security List for app"
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "ssh port"
    tcp_options {
      max = var.app_instance_ssh_port
      min = var.app_instance_ssh_port
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "Http(s) port"
    tcp_options {
      max = 80
      min = 80
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "ssh port"
    tcp_options {
      max = 443
      min = 443
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "ssh port"
    tcp_options {
      max = 7080
      min = 7080
    }
  }
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  defined_tags = {
    "Romira-s-Tags.Always-Free" = "true"
  }
}

resource "oci_core_subnet" "public_app_subnet" {
  vcn_id         = oci_core_vcn.app_vcn.id
  cidr_block     = "172.16.0.0/24"
  compartment_id = var.compartment_id
  display_name   = "public app subnet"
  dns_label      = "main"
  route_table_id = oci_core_route_table.route_table_for_public_subnet.id
  security_list_ids = [
    oci_core_security_list.security_list_for_app.id
  ]

  defined_tags = {
    "Romira-s-Tags.Always-Free" = "true"
  }
}
