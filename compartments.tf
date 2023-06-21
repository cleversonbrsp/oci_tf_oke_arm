resource "oci_identity_compartment" "lab01_comp" {
  compartment_id = var.oci_root_compartment
  description    = "OKE ARM Homolog"
  name           = "oke_arm_hml"
  enable_delete  = true
}