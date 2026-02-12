output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "vpc_self_link" {
  value = google_compute_network.vpc.self_link
}

output "public_subnet_names" {
  value = [for s in google_compute_subnetwork.public : s.name]
}

output "private_subnet_names" {
  value = [for s in google_compute_subnetwork.private : s.name]
}

output "router_name" {
  value = google_compute_router.router.name
}

output "default_internet_route_name" {
  value = google_compute_route.default_internet.name
}

output "firewall_rules" {
  value = [
    google_compute_firewall.allow_ssh.name,
    google_compute_firewall.allow_http_https.name,
    google_compute_firewall.allow_app_port.name,
    google_compute_firewall.deny_all_ingress.name
  ]
}