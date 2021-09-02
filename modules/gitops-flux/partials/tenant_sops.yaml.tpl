creation_rules:
%{ for id, env in environments ~}
  - path_regex: (\.secrets/)?${env.name}/.*\.ya?ml
    encrypted_regex: ^(data|stringData)$
    pgp: "${fingerprints_env[id].fingerprint}"

%{ endfor ~}
  - path_regex: .*\.ya?ml
    encrypted_regex: ^(data|stringData)$
    pgp: >-
%{ for fp in split(" ", join(", ", fingerprints_all)) ~}
      ${fp}
%{ endfor ~}
