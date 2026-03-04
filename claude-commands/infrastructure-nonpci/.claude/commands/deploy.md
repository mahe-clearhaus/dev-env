Deploy a service to an environment.

Usage: /deploy <service> <environment>

Arguments: $ARGUMENTS

Parse the arguments: the first word is the service, the second is the environment.

Supported services: hydra
Supported environments: test, stag

If the service or environment is not in the supported list, halt immediately and tell the user.

---

## Step 1: Check for uncommitted changes in the service repo

Run: `git -C ~/src/$SERVICE status --short`

If there are uncommitted changes, show them to the user with `git -C ~/src/$SERVICE status` and `git -C ~/src/$SERVICE diff --stat`, then ask:
"There are uncommitted changes in ~/src/$SERVICE. Do you want to continue anyway?"

Wait for the user to confirm before proceeding. If they say no, halt.

## Step 2: Run chkpsh and get commit info

Run: `git -C ~/src/$SERVICE chkpsh` (using `chkpsh` as a git alias or standalone command — try `cd ~/src/$SERVICE && chkpsh`)

Actually run: `bash -c 'cd ~/src/$SERVICE && chkpsh'`

Share the full output with the user.

Then get the latest commit hash and message:
- Full SHA: `git -C ~/src/$SERVICE rev-parse HEAD`
- Short SHA: `git -C ~/src/$SERVICE rev-parse --short HEAD`
- Commit message: `git -C ~/src/$SERVICE log -1 --pretty=%s`

Ask the user:
"Do you want to deploy `<full_sha>`
<commit_message>
to **$ENVIRONMENT**?"

Wait for confirmation. If they say no, halt.

## Step 3: Verify terraform workspace

The infrastructure directory is: `stacks/ecs/spoolers/$SERVICE` (relative to the project root `/Users/martin.henriksen/src/infrastructure-nonpci`).

**IMPORTANT SAFETY CHECK**: The environment must be "test" or "stag". Never proceed if the workspace is or would be "prod", "production", or anything other than the supported environments.

Run: `bash -c 'cd /Users/martin.henriksen/src/infrastructure-nonpci/stacks/ecs/spoolers/$SERVICE && tf workspace show'`

Show the current workspace to the user.

If the current workspace does NOT match $ENVIRONMENT:
- Notify the user: "Switching workspace from <current> to $ENVIRONMENT"
- Run: `bash -c 'cd /Users/martin.henriksen/src/infrastructure-nonpci/stacks/ecs/spoolers/$SERVICE && tf workspace select $ENVIRONMENT'`
- Show the output

If the current workspace already matches $ENVIRONMENT, confirm to the user that the workspace is correct.

**Double-check**: After any workspace operation, verify the active workspace is not production. If it is or would be, halt immediately and warn the user loudly.

## Step 4: Update the image tag in service.tf

The full SHA from Step 2 will be used to update the image tag.

Read the file: `stacks/ecs/spoolers/$SERVICE/service.tf`

Find the `image_tag` line (it looks like `image_tag = "commit-<sha>"`).

Add it if it doesn't exist, update it if it does. The argument goes inside the module block alongside the other arguments.

Update it to: `image_tag = "commit-<full_sha>"`

Show the user the diff of what changed.

## Step 5: Run terraform plan

Run: `bash -c 'cd /Users/martin.henriksen/src/infrastructure-nonpci/stacks/ecs/spoolers/$SERVICE && tf plan'`

Share the full plan output with the user.

**Validate the plan**: The expected plan is **exactly**:
- 1 resource to add
- 1 resource to change
- 1 resource to destroy

This corresponds to updating the ECS task definition (new revision = add + destroy old) and updating the ECS service to point to the new task definition.

If the plan shows a different number of adds/changes/destroys, or touches unexpected resources, **halt and flag it to the user** clearly, explaining what was unexpected.

If the plan matches expectations, tell the user the plan looks as expected.

## Step 6: Final confirmation and apply command

Ask the user one final time:
"Plan looks good. Ready to apply?

To deploy, run this command yourself:
```
cd /Users/martin.henriksen/src/infrastructure-nonpci/stacks/ecs/spoolers/$SERVICE && tf apply
```"

Note: Only the user may run `tf apply`. Do not run it yourself under any circumstances.
