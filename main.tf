#VPC network
resource "google_compute_network" "vpc3_custom" {
  name                    = "vpc3-custom"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}
#subnets
resource "google_compute_subnetwork" "us_central1_subnet" {
  name          = "us-central1-subnet"
  ip_cidr_range = "10.135.0.0/20"
  region        = var.region_us_c1
  network       = google_compute_network.vpc3_custom.self_link
}
resource "google_compute_subnetwork" "us_east1_subnet" {
  name          = "us-east1-subnet"
  ip_cidr_range = "10.145.0.0/20"
  region        = var.region_us_e1
  network       = google_compute_network.vpc3_custom.self_link 
}
#firewall
resource "google_compute_firewall" "allow_health_check" {
  name    = "vpc3-custom-allow-health-check"
  network = google_compute_network.vpc3_custom.name
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] #IP of the monitors
  allow {
    protocol = "tcp"
    ports    = ["80"] #allowing www connections
  }
}

#allow SSH and PING 
resource "google_compute_firewall" "allow_ssh" {
  name    = "vpc3-custom-allow-ssh"
  network = google_compute_network.vpc3_custom.name
  source_ranges = ["0.0.0.0/0"] #all/no range
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
resource "google_compute_firewall" "allow_http_web" {
  name    = "vpc3-custom-allow-http"
  network = google_compute_network.vpc3_custom.name
  priority = 65534
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
resource "google_compute_firewall" "allow_icmp" {
  name    = "vpc3-custom-allow-icmp"
  network = google_compute_network.vpc3_custom.name
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "icmp"
  }
}
#allow custom
resource "google_compute_firewall" "allow_custom" {
  name    = "vpc3-custom-allow-custom"
  network = google_compute_network.vpc3_custom.name
  source_ranges = ["10.0.0.0/8"]
  allow {
    protocol = "all"
  }
}
#global health check
resource "google_compute_health_check" "global_http_health_check" {
  name = "global-http-health-check"
  http_health_check {
    port = 80 #checks if connection to www works
  }
}
resource "google_compute_instance_template" "it_us_central1" {
  name_prefix  = "it-lbdemo-us-central1-"
  machine_type = "e2-micro"
  region       = var.region_us_c1
  
  metadata = {
    startup-script = file("${path.module}/nginix-vpc.sh")
  }

  disk {
    source_image = "debian-cloud/debian-12"
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.us_central1_subnet.self_link
    access_config {
      #public IP
    }
  }
}

#MIG
resource "google_compute_region_instance_group_manager" "mig1_us_central1" {
  name     = "mig1-us-central1"
  region   = var.region_us_c1
  base_instance_name = "mig1-instance"
  target_size = 2 #VM
  
  #2 different zones
  distribution_policy_zones = ["${var.region_us_c1}-b", "${var.region_us_c1}-c"]

  version {
    instance_template = google_compute_instance_template.it_us_central1.self_link
  }
  
  auto_healing_policies {
    health_check = google_compute_health_check.global_http_health_check.self_link 
    initial_delay_sec = 300 
}
  
  named_port {
    name = "webserver80" #Load Balancer
    port = 80
  }
}
resource "google_compute_instance_template" "it_us_east1" {
  name_prefix  = "it-lbdemo-us-east1-"
  machine_type = "e2-micro"
  region       = var.region_us_e1
  
  metadata = {
    startup-script = file("${path.module}/nginix-vpc.sh")
  }

  disk {
    source_image = "debian-cloud/debian-12"
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.us_east1_subnet.self_link
    access_config {
    }
  }
}

#2nd MIG
resource "google_compute_region_instance_group_manager" "mig2_us_east1" {
  name     = "mig2-us-east1"
  region   = var.region_us_e1
  base_instance_name = "mig2-instance"
  target_size = 2 
  
  distribution_policy_zones = ["${var.region_us_e1}-c", "${var.region_us_e1}-d"]

  version {
    instance_template = google_compute_instance_template.it_us_east1.self_link
  }
  
  auto_healing_policies {
    health_check = google_compute_health_check.global_http_health_check.self_link
    initial_delay_sec = 300
  }
  
  named_port {
    name = "webserver80"
    port = 80
  }
}
