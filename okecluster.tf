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