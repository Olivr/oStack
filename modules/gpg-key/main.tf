module "generate_key" {
  source  = "github.com/politician/terraform-shell-resource?ref=v1.4.0"
  command = <<-EOS
    mkdir -m 0700 ${path.module}/.keys-gpg

    cat >${path.module}/.keys-gpg/config-${var.name} <<EOF
        %no-protection
        Key-Type: 1
        Key-Length: ${var.key_length}
        Expire-Date: 0
        Name-Real: ${var.name}
        %{if var.comment != ""~}Name-Comment: ${var.comment} %{endif}
    EOF

    gpg --batch --verbose --generate-key ${path.module}/.keys-gpg/config-${var.name}

    gpg --batch --output ${path.module}/.keys-gpg/public-${var.name} --armor --export ${var.name}

    gpg --batch --output ${path.module}/.keys-gpg/private-${var.name} --armor --export-secret-key ${var.name}

    gpg --batch --with-colons --fingerprint ${var.name} | sed -nE "s/^fpr:+([A-Z0-9]+):*$/\1/p" > ${path.module}/.keys-gpg/fp-${var.name}

    cat ${path.module}/.keys-gpg/fp-${var.name} | xargs gpg --batch --yes --delete-secret-keys
    cat ${path.module}/.keys-gpg/fp-${var.name} | xargs gpg --batch --yes --delete-keys
    EOS
}

module "private_key" {
  source            = "github.com/politician/terraform-shell-resource?ref=v1.4.0"
  depends_on        = [module.generate_key]
  command           = "cat ${path.module}/.keys-gpg/private-${var.name}"
  sensitive_outputs = true
}

module "public_key" {
  source     = "github.com/politician/terraform-shell-resource?ref=v1.4.0"
  depends_on = [module.generate_key]
  command    = "cat ${path.module}/.keys-gpg/public-${var.name}"
}

module "fingerprint" {
  source     = "github.com/politician/terraform-shell-resource?ref=v1.4.0"
  depends_on = [module.generate_key]
  command    = "cat ${path.module}/.keys-gpg/fp-${var.name}"
}
