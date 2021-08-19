# ---------------------------------------------------------------------------------------------------------------------
# This test file configures required inputs with sensible values
# ---------------------------------------------------------------------------------------------------------------------
tenants = {
  tenant1 = {
    name         = "tenant-1"
    environments = ["stage"]
    repos = {
      repo1 = {
        name = "test"
        type = "ops"
        vcs = {
          provider            = "github"
          repo_http_url       = "https://github.com/Olivr/ostack-ns-ops-github"
          repo_ssh_url        = "ssh://git@github.com/Olivr/ostack-ns-ops-github.git"
          branch_default_name = "main"
        }
      }
    }
  }
}

environments = {
  stage = {
    name = "staging"
    clusters = {
      staging1 = {
        name            = "staging-1"
        bootstrap       = false
        gpg_fingerprint = "C3FA3D5D3A2EB8B000D819F66FC310A284A0E356"
        gpg_public_key  = <<-EOF
          -----BEGIN PGP PUBLIC KEY BLOCK-----

          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
          2ZWZH/cAMr2u0qhgjHz74gFcXzcu9udAiQ==
          =9Cw8
          -----END PGP PUBLIC KEY BLOCK-----
          EOF
      }
    }
  }
}

repo_ssh_url           = "ssh://git@github.com/Olivr/ostack-global-ops-github.git"
commit_status_http_url = "https://github.com/Olivr/ostack-global-ops-github"
deploy_keys = {
  _ci       = {}
  staging-1 = {}
}
secrets = {
  staging-1 = {}
}
