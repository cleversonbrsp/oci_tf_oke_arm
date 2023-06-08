resource "oci_identity_compartment" "lab01_comp" {
  compartment_id = var.oci_root_compartment
  description    = "lab01"
  name           = "lab01"
  enable_delete  = true
}