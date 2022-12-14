stripes-workspace-bootstrap
===========================

A small script that illustrates how to set up a stripes workspace.

Just run the script with one cli arg: the dir in which the workspace will be set up.

While `stripes workspace` may be sufficient to automatically set up a workspace, there may
be a reason to do it (half-way) manually.

This example sets up a small workspace with a platform and two stripes modules:
- `platform-complete`
- `stripes-core`
- `stripes-util`

It addresses two "topics":

1. The `stripes-util` is not taken from official repo, but instead my fork is used. It changes the 
way the effective call number is made up: Instead of whitespace, special characters are used as
call number field delimiters.

2. `platform-complete` and `stripes-core` have incompatible current versions, so we have to 
manually take care of matching versions.

