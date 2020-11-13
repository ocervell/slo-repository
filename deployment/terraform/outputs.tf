output "slo_configs" {
    value = {for k, v in module.slos: k => v.config}
}
