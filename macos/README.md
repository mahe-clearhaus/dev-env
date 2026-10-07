# macOS settings

Covers the two todo items: the App Shortcuts and the system-wide keyboard
shortcuts. `./export.sh` dumps the current machine state into this directory;
`./apply.sh` pushes it back onto a machine. Re-export after changing anything in
System Settings, then `git diff` to see what moved.

## What's here

| File | Source | Applied by |
| --- | --- | --- |
| `app-shortcuts.sh` | `NSUserKeyEquivalents` in each app's preference domain | itself (`defaults write`) |
| `symbolichotkeys.plist` | `~/Library/Preferences/com.apple.symbolichotkeys.plist` | copied back, then `killall cfprefsd` |
| `symbolichotkeys.txt` | generated from the plist | nothing — it exists so diffs are readable |

`app-shortcuts.sh` is currently the cmd+H unbindings (VS Code, Slack, Firefox),
each moved to `@^$` = cmd+ctrl+shift+H. Key syntax: `@` cmd, `~` opt, `^` ctrl,
`$` shift. Note the dict is keyed by the *exact* menu item title, which is why
this has to be done per app — "Hide Firefox" and "Hide Slack" are different
strings, so there is no All Applications entry that catches them all.

### Two gotchas

`defaults read com.apple.symbolichotkeys` reports *"domain does not exist"* even
though the plist is sitting right there — cfprefsd refuses that domain to a
terminal without Full Disk Access. So `export.sh` reads the file directly and
`apply.sh` writes it directly, rather than going through `defaults export/import`.

The numeric ids in `symbolichotkeys.plist` are opaque and undocumented by Apple.
The reliable ones:

    15-26  accessibility zoom / contrast / VoiceOver cluster
    28     save picture of screen as file       29  copy picture of screen
    30     save picture of selection as file    31  copy picture of selection
    52     toggle Dock hiding
    60     previous input source                61  next input source
    64     Spotlight                            65  Finder search window
    79,80  move left a space                    81,82  move right a space
    98     show Help menu
    118    switch to Desktop 1                  119  switch to Desktop 2
    160    Launchpad                            164  unidentified

Anything not in that list, check `symbolichotkeys.txt` and work it out from the
keycode; don't trust a table you find online without verifying.

## What can't go in here

Not everything in System Settings is backed by a plist, and some of what is
can't be written from a script:

- **Privacy & Security** — Accessibility, Input Monitoring, Full Disk Access,
  Screen Recording grants. Held in the SIP-protected TCC database; deliberately
  not scriptable. These have to be re-granted by hand, and they're the ones that
  matter for Karabiner and Raycast.
- **Login items, Touch ID, Apple Account, iCloud, Wi-Fi networks** — tied to
  keychain or per-machine identity.
- **Display arrangement and resolution** — per-display-hardware.
- **Anything an app keeps server-side** rather than in prefs.

Adding more domains is a matter of appending `defaults export <domain>` lines to
`export.sh` — but check first that the app isn't already covered by its own
package in this repo (Ghostty, Karabiner, herdr and friends all keep plain
config files, which are better tracked than a plist).
