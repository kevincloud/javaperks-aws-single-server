output "A-Site-URL" {
    value = "http://${module.server.public_ip}/"
}

output "B-vault-server" {
    value = "http://${module.server.public_ip}:8200/"
}

output "C-nomad-server" {
    value = "http://${module.server.public_ip}:4646/"
}

output "D-consul-server" {
    value = "http://${module.server.public_ip}:8500/"
}

output "E-server-ssh" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${module.server.public_ip}"
}
