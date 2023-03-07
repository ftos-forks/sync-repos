# sync-repos

This repository helps to update the repositories from the ftos-forks organization using ftos-forks/git-sync@v3.

## Features
This workflow will run every night to bring all the updates and tags to the ftos-forks repositories. In addition, a workflow dispatch trigger is set to allow manual run. 

The workflow has two jobs:
- `extract-repos` uses `gh api` to create a matrix with all pairs of source-destination repositories.
- `sync job` uses the matrix previously created and brings releases, branches and tags to the ftos-forks forked repositories using `ftos-forks/git-sync@v3` action.
