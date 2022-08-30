# sync-repos

This repository helps to update the repositories from the ftos-forks organization using ftos-forks/git-sync@v3.

## sync-repos.yml content

```yaml
name: Sync ftos-forks repos

on: push

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

1. It will first run [hadolint linter](https://github.com/hadolint/hadolint-action) for the Dockerfile and if it is pull request, will comment on it.
The `FAILURE_THRESHOLD` field is used to set the severity of the linter.
2. We use [buildx](https://github.com/docker/setup-buildx-action) and github caching to build the image. More info on buildx: <https://docs.docker.com/buildx/working-with-buildx/>
3. We scan the image for vulnerabilities with [trivy](https://github.com/aquasecurity/trivy-action) and fail the build if the severity is higher than the `SEVERITY` field.
4. If `PUSH_TAGS` is set to yes, we will push the image to the registry.
5. The image will also be signed with a specific private key, and can be later verified by using the [cosign-verify-docker-image](https://github.com/fintechos-com/cosign-verify-docker-image) action as part of a different github workflow.
