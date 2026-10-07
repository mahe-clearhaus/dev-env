Migrate a GitHub repository from individual GitHub Actions workflows to the shared workflow.

Usage: /migrate <repo>

Arguments: $ARGUMENTS

The argument is the repository name (without the `clearhaus/` org prefix).

---

You are a diligent and precise agent tasked with migrating GitHub repositories from individual GitHub Actions workflows to a shared GitHub Actions workflow.

Follow the Rules and Examples sections closely. Stop and ask if anything is inconsistent or unclear.

Always end files with a newline. When pushing files via the GitHub MCP, ensure the last character of the `content` argument is always `\n`.

Do not add comments in code unless instructed to.

## Examples

Base your migration on the following example PRs. Read them via the GitHub MCP before starting:

- https://github.com/clearhaus/subscribr/pull/260
- https://github.com/clearhaus/transactiondb-syncer/pull/23
- https://github.com/clearhaus/taskr-datalayer/pull/83

Name the new build file `build.yml` (matching whatever the deleted file was called), even if the examples use `build-and-test.yml`.

### Remove env vars from spec_helper
If there is a `spec/spec_helper.rb` that overwrites env vars, move those env vars to an env file as shown in the examples.

### Build command in Makefile
Move the build command from `build/build.sh` to the `build` target in the Makefile, then delete `build/build.sh`.

### DB service name
If the service uses a Postgres service, name it after the repo, e.g. `taskr-db`.

### Dependabot
If the repository uses `terminator.yml`, migrate it to `dependabot.yml` as shown in the examples.

Note: `dependabot.yml` requires the following permissions in the build workflow:
```
permissions:
  contents: read
  actions: write
```

### Compose commands
Add compose service commands like this, defaulting to manual start:
```
command: sleep infinity # manual start
# command: ./build/start.sh # auto start
```

## Flow

Perform the following steps in order:

1. Read the example PRs via the GitHub MCP to understand the expected migration pattern.

2. Make all the required changes to the repository as a single commit with the message `Use shared workflow`.

3. Create a sub-issue under https://github.com/clearhaus/issues-nonpci/issues/1295 (unless one already exists for this repo). Model it after https://github.com/clearhaus/issues-nonpci/issues/1817. Assign yourself to the issue.

4. Create a draft PR. Use this PR description:
   ```
   This PR was made by an AI agent.

   Closes: <link to sub-issue>

   Based on:
   - https://github.com/clearhaus/subscribr/pull/260
   - https://github.com/clearhaus/transactiondb-syncer/pull/23
   - https://github.com/clearhaus/taskr-datalayer/pull/83
   ```
   Set the "when" column to "now".

5. Leave this comment on the PR:
   ```
   Checklist
   - [ ] Can `make test` after checking out OR required commands are in top of README.md
   - [ ] Can run locally after checking out
   ```

6. Link the issue and PR to the user for review.

## Rules

If an environment needs to be seeded, default to the compose `env_file` approach:

```yaml
x-env_file: &env_file
  env_file:
    - path: .env.${APP_ENV:-test}
      required: false
    - path: .env
      required: false
```

To check PR CI status:
```sh
gh run list --repo clearhaus/<REPO> --branch $(gh pr view <PR_NUMBER> --repo clearhaus/<REPO> --json headRefName --jq '.headRefName') --limit 1
```
