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
			availability_domain = var.oci_ad
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
