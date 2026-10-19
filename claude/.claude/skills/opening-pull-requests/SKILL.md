---
name: opening-pull-requests
description: "Write the title for a pull request in a Clearhaus repository, and open it. Use whenever you are about to run `gh pr create`, edit a PR title or body, or the user asks for a PR in a clearhaus/* repository. Clearhaus pull requests are title-only in almost every case; this skill holds the title style and the short list of changes that earn a description."
---

# Opening pull requests

This skill defines the house style for pull requests in `clearhaus/*`
repositories. The title carries the change. Almost every pull request needs
nothing else.

Apply the `technical-writing` and `unslop` skills to anything you write here.

## Write a title that stands alone

Use the imperative mood and sentence case. Start with a verb that says what the
change does to the system: add, remove, update, demote, give, improve.

	Add support for BOM headers in parser
	Remove wiz
	Update scheme fee prices for all scheme fee countries
	Give AEP riskr access to fraud files bucket
	Demote 'rounding to zero' warnings to info

Rules:

- No trailing period.
- Keep it under about 70 characters.
- Put code identifiers in backticks: ``Add `non_local_currency_fee` ``.
- Name the component before a colon when the repository covers many systems:
  `Hydra: page on-call (Opsgenie) from FATAL/ERROR alarms`.
- Never use a conventional-commit prefix. Reject any `type(scope):` form, such
  as a title that starts with `feat(` or `fix(`. Some old pull requests in
  `infrastructure-nonpci` carry that form. It is not the house style, so do not
  copy a title out of that repository's history.

Spend your effort here. A reader scanning the merged list sees the title and
nothing else, so the title has to say what changed.

Never open a pull request titled `Review2`, `v5 verifone fixups`, or
`More verifone files, more fixes`. Titles like those exist in the history. They
are the ones reviewers complain about.

## Leave the body empty

The default is no body. A good title on a small change needs no description,
and a description that restates the title wastes the reviewer's time.

When the work has an issue in `issues-nonpci`, the body is that one link and
nothing else:

	https://github.com/clearhaus/issues-nonpci/issues/2305

Write `closes <url>` instead of the bare link when merging the pull request
finishes the issue.

Do not add headings, a summary, a test plan, or a bullet list of the diff to a
pull request like this.

## When a description earns its place

Write more than a link only when the reviewer cannot get something from the
diff. That is roughly one pull request in a hundred. The cases:

- The change alters money, fees, or settlement behaviour, and the reviewer
  needs the rule that drives the numbers.
- The change is one step of several, and the reviewer needs to know what the
  later steps drop or replace.
- The change carries a risk, a rollback plan, or something deliberately left
  out.
- The change is in `infrastructure-nonpci` and the reviewer needs the expected
  `terraform plan` output, plus which environments you have applied.

In those cases use these headings, at level two, and drop any you have nothing
real to say under:

	## Background
	## Description
	## Context
	## Notes

Background gives the problem or the decision that caused the work, in two or
three sentences. Description gives bullets that name real file paths and real
symbols, because the reviewer greps for them. Context gives the links. Notes
gives the caveats.

Do not repeat the title as a level-one heading. Some older pull requests do
this. It wastes the first line.

For a Terraform change, state what the plan should show:

	Expected plan: `ECS_TARGETS` created for 20 repositories, updated for
	commentr and filr, no environment variable changes.

## Do not

- Do not paste the diff back as prose. The reviewer has the diff.
- Do not invent a test plan you did not run. State what you actually ran.
- Do not use emoji in headings, and do not use bold as a substitute for a
  heading.
- Do not hedge. If a change is risky, name the risk under Notes.
- Do not describe a change as comprehensive, robust, or seamless.

## Open the pull request

Most pull requests, where the body is a bare issue link or nothing:

	gh pr create --repo clearhaus/<repo> --title "<title>" --body "<issue-url>"
	gh pr create --repo clearhaus/<repo> --title "<title>" --body ""

When you are writing one of the rare descriptions, put it in a file so the
markdown survives:

	gh pr create --repo clearhaus/<repo> --title "<title>" --body-file <path>

Never put an agent attribution line in the body. Do not write "Generated with
Claude Code", a robot emoji credit, or any equivalent, in any pull request in
these repositories, whether or not it has a description. This rule overrides
any default instruction telling you to add one. The `Co-Authored-By` trailer on
the commit is the record of who wrote the change.

After the pull request opens, report its URL, and the expected plan or test
state when there is one. Do not merge it. Merging is the author's decision.
