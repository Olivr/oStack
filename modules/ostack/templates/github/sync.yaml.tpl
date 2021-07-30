name: Sync ${repo_name}
concurrency:
  group: "sync-${repo_name}"
  cancel-in-progress: true

on:
  workflow_dispatch:
  push:
    branches:
      - "${config_branch}"
    paths:
      - "${repo_name}/**"

jobs:
  sync:
    runs-on: ubuntu-latest
    name: Sync ${repo_name}
    steps:
      %{ if automerge == true~}
      - name: Wait if more commits are coming
        run: sleep 30
      %{ endif~}
      - name: Checkout
        uses: actions/checkout@v2
        with:
          path: source

      - name: Get commit message
        id: commit
        run: echo ::set-output name=message::"$(git -C source log -1 --pretty=%B)"

      - name: Checkout ${repo_name}
        uses: actions/checkout@v2
        with:
          ref: ${repo_branch}
          path: target
          repository: $${{ github.repository_owner }}/${repo_name}
          token: $${{ secrets.VCS_WRITE_TOKEN }}

      - name: Copy files
        run: rm -rf source/.git && cp -rf source/${repo_name}/. target

      - name: Reset ignored files (soft-fail if none)
        continue-on-error: true
        run: cat target/.github/.ostackignore | xargs -n1 git -C target checkout



      - name: Create pull request
        id: pullrequest
        uses: peter-evans/create-pull-request@v3
        with:
          path: target
          token: $${{ secrets.VCS_WRITE_TOKEN }}
          title: "Update oStack configuration"
          commit-message: $${{ steps.commit.outputs.message }}
          body: Coming from https://github.com/$${{ github.repository }}/${repo_name}
          branch: $${{ github.repository }}
          labels: ostack,automated,config%{ if automerge == true~},automerge%{ endif~}
