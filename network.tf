resource "oci_core_vcn" "generated_oci_core_vcn" {
	cidr_block = "10.0.0.0/16"
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-vcn"
	dns_label = "cluster1"
}

resource "oci_core_internet_gateway" "generated_oci_core_internet_gateway" {
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-igw"
	enabled = "true"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_subnet" "service_lb_subnet" {
	cidr_block = "10.0.20.0/24"
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-svclbsubnet"
	dns_label = "svclbsubnet"
	prohibit_public_ip_on_vnic = "false"
	route_table_id = "${oci_core_default_route_table.generated_oci_core_default_route_table.id}"
	security_list_ids = ["${oci_core_vcn.generated_oci_core_vcn.default_security_list_id}"]
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_subnet" "node_subnet" {
	cidr_block = "10.0.10.0/24"
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-nodesubnet"
	dns_label = "nodesubnet"
	prohibit_public_ip_on_vnic = "false"
	route_table_id = "${oci_core_default_route_table.generated_oci_core_default_route_table.id}"
	security_list_ids = ["${oci_core_security_list.node_sec_list.id}"]
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_subnet" "kubernetes_api_endpoint_subnet" {
	cidr_block = "10.0.0.0/28"
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-k8sApiEndpoint-subnet"
	dns_label = "k8sApiEndpoint"
	prohibit_public_ip_on_vnic = "false"
	route_table_id = "${oci_core_default_route_table.generated_oci_core_default_route_table.id}"
	security_list_ids = ["${oci_core_security_list.kubernetes_api_endpoint_sec_list.id}"]
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_default_route_table" "generated_oci_core_default_route_table" {
	display_name = "default"
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
	display_name = "oke-svclbseclist-quick-cluster1"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_security_list" "node_sec_list" {
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "node_sec_list"

	egress_security_rules {
		description = "Worker Nodes access to Internet."
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}

	ingress_security_rules {
		description = "Warning! All traffic for all ports from everywhere."
		protocol = "all"
		source = "0.0.0.0/0"
		stateless = "false"
	}
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_security_list" "kubernetes_api_endpoint_sec_list" {
	compartment_id = oci_identity_compartment.lab01_comp.id
	display_name = "oke-k8sApiEndpoint-quick-cluster1"

	egress_security_rules {
		description = "Worker Nodes access to Internet."
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}
	
	ingress_security_rules {
		description = "External access to Kubernetes API endpoint."
		protocol = "all"
		source = "0.0.0.0/0"
		stateless = "false"
	}
	
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}