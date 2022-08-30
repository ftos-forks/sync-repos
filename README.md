# sync-repos

This repository helps to update the repositories from the ftos-forks organization using ftos-forks/git-sync@v3.

## sync-repos.yml content

```yaml
name: Sync ftos-forks repos

on:
  schedule:
    - cron: "0 2 * * *"

jobs:
  extract-repos:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: Bash Script
      shell: 'bash'
      env:
        GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      run: |
        chmod +x ./scripts/extract.sh
        sh ./scripts/extract.sh > ./.github/source-dest.json
  setup:
        runs-on: ubuntu-20.04
        needs: [extract-repos]
        outputs:
          matrix: ${{ steps.setup-matrix.outputs.matrix }}
        steps:
          - name: Checkout code
            uses: ftos-forks/checkout@v2
          - name: Get strategy configuration
            id: setup-matrix
            uses: ftos-forks/conditional-build-matrix@0.1.0
            with:
              inputFile: './.github/source-dest.json'
              filter: '[?Source]'
          - name: Print Matrix 
            run: echo "matrix content ${{ steps.setup-matrix.outputs.matrix }} "
                     
  sync-job:
        runs-on: ubuntu-latest
        needs: [setup]
        continue-on-error: false
        strategy:
          fail-fast: true
          max-parallel: 4
          matrix: ${{fromJson(needs.setup.outputs.matrix)}}
        steps:
          - name: git-sync
            uses: wei/git-sync@v3
            with:
              source_repo: ${{ matrix.Source }}
              source_branch: "refs/remotes/source/*"
              destination_repo: ${{ matrix.Destination }}
              destination_branch: "refs/heads/*"
              ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
          - name: git-sync-tags
            uses: wei/git-sync@v3
            with:
              source_repo: ${{ matrix.Source }}
              source_branch: "refs/tags/*"
              destination_repo: ${{ matrix.Destination }}
              destination_branch: "refs/tags/*"
              ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
```

## Features
1. This workflow will run every night to bring all the updates and tags to the ftos-forks repositories.
2. The workflow has three jobs. The first (extract-repos) runs the script in sync-repos/scripts so that the json file in sync-repos/.github ends up having all pairs of source-destination repositories.
3. The setup job helps to put the information from the json file in a matrix to be able to sync between the repositories in the next job.
4. In the sync-job, updates and tags are brought to the repositories from ftos-forks using ftos-forks/git-sync@v3 action and the information from the matrix created in the previous job.
