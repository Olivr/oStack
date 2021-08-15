creation_rules:
%{ for id, env in environments ~}
%{ for cluster in env.clusters ~}
%{ if cluster.gpg_fingerprint != null ~}
  - path_regex: (\.secrets/)?${env.name}/${cluster.name}/.*\.ya?ml
    encrypted_regex: ^(data|stringData)$
    pgp: "${cluster.gpg_fingerprint}"

%{ endif ~}
%{ endfor ~}
  - path_regex: (\.secrets/)?${env.name}/.*\.ya?ml
    encrypted_regex: ^(data|stringData)$
    pgp: >-
%{ for fp in split(" ", join(", ", fingerprints_env[id])) ~}
      ${fp}
%{ endfor ~}

%{ endfor ~}
  - path_regex: .*\.ya?ml
    encrypted_regex: ^(data|stringData)$
    pgp: >-
%{ for fp in split(" ", join(", ", fingerprints_all)) ~}
      ${fp}
%{ endfor ~}
