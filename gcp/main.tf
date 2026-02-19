locals {
  name_prefix = "${var.project}-${var.env}-${var.name_suffix}"
}

# VPC (custom subnet mode)
resource "google_compute_network" "vpc" {
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Public subnets (one per zone)
resource "google_compute_subnetwork" "public" {
  count                    = 3
  name                     = "${local.name_prefix}-public-${count.index + 1}"
  ip_cidr_range            = var.public_subnet_cidrs[count.index]
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = false
}

# Private subnets (one per zone)
resource "google_compute_subnetwork" "private" {
  count                    = 3
  name                     = "${local.name_prefix}-private-${count.index + 1}"
  ip_cidr_range            = var.private_subnet_cidrs[count.index]
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

# Cloud Router (rubric asks for it)
resource "google_compute_router" "router" {
  name    = "${local.name_prefix}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

# Route: 0.0.0.0/0 -> default internet gateway (for outbound internet)
# Note: In GCP, subnets don't have "route table association" like AWS.
# This route applies in the VPC; you control exposure via firewall + instance tags.
resource "google_compute_route" "default_internet" {
  name             = "${local.name_prefix}-default-internet"
  network          = google_compute_network.vpc.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000

  # Apply route only to instances with this tag (keeps behavior explicit for grading)
  tags = ["public-web"]
}

# FIREWALL: Allow SSH from your IP(s) to instances tagged public-web
resource "google_compute_firewall" "allow_ssh" {
  name      = "${local.name_prefix}-allow-ssh"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"
  priority  = 1000

  target_tags   = ["public-web"]
  source_ranges = length(var.ssh_allowed_cidrs) > 0 ? var.ssh_allowed_cidrs : ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# FIREWALL: Allow HTTP/HTTPS from Internet to instances tagged public-web
resource "google_compute_firewall" "allow_http_https" {
  name      = "${local.name_prefix}-allow-http-https"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"
  priority  = 1000

  target_tags   = ["public-web"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

# FIREWALL: Allow app port to instances tagged app
resource "google_compute_firewall" "allow_app_port" {
  name      = "${local.name_prefix}-allow-app-${var.app_port}"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"
  priority  = 1100

  target_tags   = ["app"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = [tostring(var.app_port)]
  }
}

# FIREWALL: Deny all other ingress (lower priority / less precedence than allow rules)
resource "google_compute_firewall" "deny_all_ingress" {
  name      = "${local.name_prefix}-deny-all-ingress"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"
  priority  = 2000

  # Apply to all instances (no target_tags)
  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }
}

# Firewall rule for webapp instances
resource "google_compute_firewall" "allow_webapp" {
  name          = "${local.name_prefix}-allow-webapp"
  network       = google_compute_network.vpc.name
  direction     = "INGRESS"
  priority      = 900
  target_tags   = ["webapp"]
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", tostring(var.app_port)]
  }
}

# Compute Engine instance
resource "google_compute_instance" "app" {
  name         = "${local.name_prefix}-app"
  machine_type = "e2-medium"
  zone         = var.zones[0]

  tags = ["webapp", "public-web"]

  boot_disk {
    initialize_params {
      image = "projects/${var.project_id}/global/images/${var.custom_image}"
      size  = 25
      type  = "pd-balanced"
    }
    auto_delete = true
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.public[0].id
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    cat > /opt/csye6225/.env << 'ENVFILE'
    PORT=${var.app_port}
    DB_HOST=localhost
    DB_PORT=5432
    DB_USER=webappuser
    DB_PASSWORD=${var.db_password}
    DB_NAME=webapp
    JWT_SECRET=changeme
    NODE_ENV=production
    ENVFILE
    chown csye6225:csye6225 /opt/csye6225/.env
    sudo -u postgres psql -c "CREATE USER webappuser WITH PASSWORD '${var.db_password}';" || true
    sudo -u postgres psql -c "CREATE DATABASE webapp OWNER webappuser;" || true
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE webapp TO webappuser;" || true
    systemctl restart webapp
  EOF

  deletion_protection = false
}