resource "oci_core_vcn" "generated_oci_core_vcn" {
	cidr_block = "10.0.0.0/16"
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-vcn-quick-cluster1-f9b2e359d"
	dns_label = "cluster1"
}

resource "oci_core_internet_gateway" "generated_oci_core_internet_gateway" {
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-igw-quick-cluster1-f9b2e359d"
	enabled = "true"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_subnet" "service_lb_subnet" {
	cidr_block = "10.0.20.0/24"
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-svclbsubnet-quick-cluster1-f9b2e359d-regional"
	dns_label = "lbsub53aba4c45"
	prohibit_public_ip_on_vnic = "false"
	route_table_id = "${oci_core_default_route_table.generated_oci_core_default_route_table.id}"
	security_list_ids = ["${oci_core_vcn.generated_oci_core_vcn.default_security_list_id}"]
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_subnet" "node_subnet" {
	cidr_block = "10.0.10.0/24"
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-nodesubnet-quick-cluster1-f9b2e359d-regional"
	dns_label = "subb7bdfb878"
	prohibit_public_ip_on_vnic = "false"
	route_table_id = "${oci_core_default_route_table.generated_oci_core_default_route_table.id}"
	security_list_ids = ["${oci_core_security_list.node_sec_list.id}"]
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_subnet" "kubernetes_api_endpoint_subnet" {
	cidr_block = "10.0.0.0/28"
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-k8sApiEndpoint-subnet-quick-cluster1-f9b2e359d-regional"
	dns_label = "sub5d403305d"
	prohibit_public_ip_on_vnic = "false"
	route_table_id = "${oci_core_default_route_table.generated_oci_core_default_route_table.id}"
	security_list_ids = ["${oci_core_security_list.kubernetes_api_endpoint_sec_list.id}"]
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_default_route_table" "generated_oci_core_default_route_table" {
	display_name = "oke-public-routetable-cluster1-f9b2e359d"
	route_rules {
		description = "traffic to/from internet"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		network_entity_id = "${oci_core_internet_gateway.generated_oci_core_internet_gateway.id}"
	}
	manage_default_resource_id = "${oci_core_vcn.generated_oci_core_vcn.default_route_table_id}"
}

resource "oci_core_security_list" "service_lb_sec_list" {
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-svclbseclist-quick-cluster1-f9b2e359d"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_security_list" "node_sec_list" {
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-nodeseclist-quick-cluster1-f9b2e359d"
	egress_security_rules {
		description = "Allow pods on one worker node to communicate with pods on other worker nodes"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}
	egress_security_rules {
		description = "Access to Kubernetes API Endpoint"
		destination = "10.0.0.0/28"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "Kubernetes worker to control plane communication"
		destination = "10.0.0.0/28"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "Path discovery"
		destination = "10.0.0.0/28"
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	egress_security_rules {
		description = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
		destination = "all-gru-services-in-oracle-services-network"
		destination_type = "SERVICE_CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "ICMP Access from Kubernetes Control Plane"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	egress_security_rules {
		description = "Worker Nodes access to Internet"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Allow pods on one worker node to communicate with pods on other worker nodes"
		protocol = "all"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Path discovery"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		source = "10.0.0.0/28"
		stateless = "false"
	}
	ingress_security_rules {
		description = "TCP access from Kubernetes Control Plane"
		protocol = "6"
		source = "10.0.0.0/28"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Inbound SSH traffic to worker nodes"
		protocol = "6"
		source = "0.0.0.0/0"
		stateless = "false"
	}
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_security_list" "kubernetes_api_endpoint_sec_list" {
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-k8sApiEndpoint-quick-cluster1-f9b2e359d"
	egress_security_rules {
		description = "Allow Kubernetes Control Plane to communicate with OKE"
		destination = "all-gru-services-in-oracle-services-network"
		destination_type = "SERVICE_CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "All traffic to worker nodes"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "Path discovery"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	ingress_security_rules {
		description = "External access to Kubernetes API endpoint"
		protocol = "6"
		source = "0.0.0.0/0"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Kubernetes worker to Kubernetes API endpoint communication"
		protocol = "6"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Kubernetes worker to control plane communication"
		protocol = "6"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Path discovery"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_containerengine_cluster" "generated_oci_containerengine_cluster" {
	compartment_id = oci_identity_compartment.lab01_comp.id
	endpoint_config {
		is_public_ip_enabled = "true"
		subnet_id = "${oci_core_subnet.kubernetes_api_endpoint_subnet.id}"
	}
	freeform_tags = {
		"OKEclusterName" = "cluster1"
	}
	kubernetes_version = "v1.26.2"
	name = "cluster1"
	options {
		admission_controller_options {
			is_pod_security_policy_enabled = "false"
		}
		persistent_volume_config {
			freeform_tags = {
				"OKEclusterName" = "cluster1"
			}
		}
		service_lb_config {
			freeform_tags = {
				"OKEclusterName" = "cluster1"
			}
		}
		service_lb_subnet_ids = ["${oci_core_subnet.service_lb_subnet.id}"]
	}
	type = "BASIC_CLUSTER"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_containerengine_node_pool" "create_node_pool_details0" {
	cluster_id = "${oci_containerengine_cluster.generated_oci_containerengine_cluster.id}"
	compartment_id = oci_identity_compartment.lab01_comp.id
	freeform_tags = {
		"OKEnodePoolName" = "pool1"
	}
	initial_node_labels {
		key = "name"
		value = "cluster1"
	}
	kubernetes_version = "v1.26.2"
	name = "pool1"
	node_config_details {
		freeform_tags = {
			"OKEnodePoolName" = "pool1"
		}
		placement_configs {
			availability_domain = "oEOm:SA-SAOPAULO-1-AD-1"
			subnet_id = "${oci_core_subnet.node_subnet.id}"
		}
		size = "1"
	}
	node_eviction_node_pool_settings {
		eviction_grace_duration = "PT60M"
	}
	node_shape = "VM.Standard.A1.Flex"
	node_shape_config {
		memory_in_gbs = "6"
		ocpus = "1"
	}
	node_source_details {
		image_id = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaah7m4nus64tzymxesxnkohxpngui4z5fmflrk3uzzq3tdsbhcnh5a"
		source_type = "IMAGE"
	}
	ssh_public_key = var.node_pub_key
}
