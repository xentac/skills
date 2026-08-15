# Devcontainer Egress Firewall

## Recognizing a block

This mechanism is iptables `DROP`/`REJECT`, not an HTTP-level proxy — a block looks different from the 403-with-explanation you'd get from `agent-sandbox-env`'s network policy. Expect a **connection timeout** (dropped) or **connection refused** (rejected) depending on which rule catches it — a plain "curl: (7) Failed to connect" or a hang with no response body. If a request to a host that should be reachable times out or is refused rather than erroring cleanly, suspect this firewall before assuming a DNS or app-level problem.

Some devcontainers (not all) run a default-deny egress firewall via a `postStartCommand` script, typically named something like `init-firewall.sh` under `.devcontainer/`. This is a per-project convention, not something the devcontainers CLI provides on its own — check the project's `devcontainer.json` for a `postStartCommand` and read the script it points to before assuming this pattern applies, or that a particular domain is (or isn't) allowed.

## Recognizing it

```bash
grep -i postStartCommand .devcontainer/devcontainer.json
```

If it points at a script, read that script — it defines the actual mechanism and allowlist for *this* project. Don't carry over another project's allowlist.

## Worked example: torn_war_monitor

`torn_war_monitor`'s `.devcontainer/init-firewall.sh` implements the pattern like this:

- **iptables + ipset.** An ipset named `allowed-domains` (`hash:net`) holds every allowed destination.
- **Always allowed:** DNS, loopback, the host's `/24`.
- **GitHub's published IP ranges** are fetched from `https://api.github.com/meta` and added as CIDR blocks.
- **A fixed list of single domains** (in this project: `api.anthropic.com`, `claude.ai`, `platform.claude.com`, `registry.npmjs.org`, `crates.io`, `static.crates.io`, `index.crates.io`) is resolved via `dig` and added by IP **at script-run time**.
- **Default policy** is then set to `DROP` on `OUTPUT`, with an explicit `REJECT` catch-all after the allowlist `ACCEPT` rule.

Treat the mechanism (iptables + ipset, GitHub ranges via API, fixed domains via `dig`) as the generalizable pattern, and the specific domain list as specific to torn_war_monitor — other projects' scripts will allow different things.

## Granting a new host access

Edit the script, not the live ruleset:

- **Single resolvable host** → add it to the `for domain in ...` loop.
- **Whole IP range** → add a CIDR block the way the GitHub-ranges section does.

Then reload — in torn_war_monitor this is:

```bash
sudo bash .devcontainer/init-firewall.sh
```

which is exactly what `postStartCommand` runs on every container start.

**Check sudo scope before assuming you can run this.** In torn_war_monitor, `/etc/sudoers.d/vscode-firewall` grants the container user passwordless sudo scoped to *exactly* that command string — not broad sudo access. Look for a similarly scoped sudoers file in other projects (e.g. `/etc/sudoers.d/*firewall*`) rather than assuming free rein to `sudo`.

## Caveat: rotating-IP domains go stale

Domains behind a CDN with rotating IPs get baked into the ipset as a DNS snapshot at script-run time, not a live rule. If a request to an already-allowlisted domain starts failing, re-running the firewall script (which re-resolves DNS) is a reasonable first thing to try before assuming the domain needs to be added.

## Caveat: the claude-code devcontainer feature can clobber a custom script

If a project uses the official `claude-code` devcontainer feature *alongside* a custom firewall script, check where the script physically lives before editing it. The claude-code feature unconditionally overwrites `/usr/local/bin/init-firewall.sh` during its own install step. torn_war_monitor avoids this by bind-mounting its script from the workspace (`.devcontainer/init-firewall.sh`) rather than `COPY`ing it into that exact path in the Dockerfile. If a project's Dockerfile has a `COPY .../init-firewall.sh /usr/local/bin/init-firewall.sh` alongside the claude-code feature, flag that it will get silently overwritten on rebuild.
