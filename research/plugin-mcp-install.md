# How plugins and other agents install an MCP server and give it secrets

Research for issue #2 (map: issue #1). All sources were fetched on 2026-10-21.
Items marked **Unconfirmed** are not stated by any primary source that was read.

## Short answer

- A Claude Code plugin declares an MCP server in `.mcp.json` at the plugin root, or inline under `mcpServers` in `.claude-plugin/plugin.json`.
- The plugin asks the user for the key with `userConfig` and `"sensitive": true`. The server config puts the value in the process environment with `"env": { "TORN_API_KEY": "${user_config.torn_api_key}" }`.
- Claude Code stores a sensitive value in the macOS Keychain. On Linux and Windows it stores the value in `~/.claude/.credentials.json`. That file is plain text on disk.
- The most portable launch is `npx -y <package>@<version>` or `uvx <package>@<version>`. Then the server block has no plugin path in it, and the same block works in every agent. `npx` needs Node.js on the user's PATH. `uvx` needs uv on the user's PATH. No agent installs these for the user.
- No standard defines a way for a plugin to ask for a secret. Claude Code has `userConfig`. Gemini CLI extensions have `settings`. Codex, Cursor, and the Agent Plugins 1.0 standard have nothing. The common ground is this: the server reads its key from an environment variable with a fixed name.
- `npx skills add` installs skills only. It never installs or configures an MCP server.

## 1. Claude Code plugins

### 1.1 Where a plugin declares a server

- The default location is `.mcp.json` at the plugin root. The `mcpServers` key in `plugin.json` can also take an inline map, a path to a `.json` file, a `.mcpb` bundle, or an array of these. Claude Code loads `.mcp.json` first. A server name declared later replaces an earlier one. [manifest-reference]
- In `.mcp.json` you can omit the `mcpServers` wrapper and put each server at the top level. [components]
- A stdio server entry has `command`, `args`, and `env`. Example from the docs:
  ```json
  { "mcpServers": { "db": { "command": "node", "args": ["${CLAUDE_PLUGIN_ROOT}/server.js"] } } }
  ```
  [components]
- In `/mcp` the server shows as `plugin:<plugin>:<server>`. Tool names are `mcp__plugin_<plugin>_<server>__<tool>`. [components]
- The user adds and removes a plugin server by installing or uninstalling the plugin. The user can still turn the server off in `/mcp`. [mcp]
- When a marketplace entry has a `plugin.json`, the entry's `mcpServers` and `userConfig` do not apply. Declare them in `plugin.json`. [marketplace-reference]
- `claude plugin validate` checks MCP entries. It reports a `${user_config.KEY}` reference to an undeclared option as an error. This needs Claude Code v2.1.281 or later. [manifest-reference]

### 1.2 Path variables

| Variable | Value |
| :- | :- |
| `${CLAUDE_PLUGIN_ROOT}` | The installed version's directory. It changes on every update. Do not write state there. |
| `${CLAUDE_PLUGIN_DATA}` | `~/.claude/plugins/data/<id>/`. It survives updates. Use it for `node_modules`, virtual environments, and caches. |
| `${CLAUDE_PROJECT_DIR}` | The project root. |

- For a stdio server, these variables are substituted in `command`, `args`, and `env`. `CLAUDE_PLUGIN_ROOT` and `CLAUDE_PLUGIN_DATA` are also exported to the server process. [manifest-reference]
- These variables are not present in the environment of the Bash tool. [manifest-reference]
- A marketplace plugin is copied into `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`. Files outside the plugin directory are not copied. [loading]

### 1.3 How a secret reaches the server

1. The manifest declares the option:
   ```json
   "userConfig": {
     "torn_api_key": {
       "type": "string",
       "title": "Torn API key",
       "description": "A Limited Access key from your Torn settings",
       "sensitive": true,
       "required": true
     }
   }
   ```
   `sensitive: true` masks the input and stores the value in secure storage, not in `settings.json`. [manifest-reference]
2. The server config references it in `env`:
   ```json
   "env": { "TORN_API_KEY": "${user_config.torn_api_key}" }
   ```
   `${user_config.KEY}` is substituted in MCP server config. The docs' Telegram channel example puts a sensitive token in a stdio server's `env` this way. [manifest-reference]
3. Put the key in `env`, never in `args`. Other local users can see a process's arguments.

Other facts about `userConfig`:

- In skill and agent text, a sensitive value becomes a placeholder. So the key never enters the model's context through a skill. [manifest-reference]
- Hooks get every option as `CLAUDE_PLUGIN_OPTION_<KEY>`. Monitors and `headersHelper` get no option values. [manifest-reference]
- Storage: non-sensitive values go under `pluginConfigs` in the user's `settings.json`. Sensitive values go to the macOS Keychain. If the Keychain rejects the write, Claude Code uses `~/.claude/.credentials.json`. On platforms without a supported keychain, Claude Code also uses `~/.claude/.credentials.json`. [settings-reference]
- Uninstalling a plugin from its last scope deletes its stored options and secrets and its data directory. [cli-reference]

When the user is asked for the value:

- If the user installs the plugin in `/plugin`, runs `/plugin install` in a session, or enables it in the **Installed** tab, the dialog opens. `/plugin configure <plugin>@<marketplace>` opens it again. [components]
- The shell command `claude plugin install` never prompts. It accepts `--config KEY=VALUE`. That puts the key in argv and shell history, so do not recommend it for the key. [components] [cli-reference]
- `claude plugin configure <plugin>@<marketplace> --values-stdin` reads a JSON object from stdin. The key stays out of argv. A user with sops can pipe the decrypted JSON into this command. This needs Claude Code v2.1.285 or later. [cli-reference]

**Unconfirmed:** the stdio server's value for an unset `${user_config.KEY}`. The docs answer this only for a remote `url` (`URL is unset or invalid`). Three results are possible: an empty value, the literal text, or no server start. Design rule: if the key is missing or looks like a placeholder, the server must stop with a clear message.

**Unconfirmed:** whether a stdio server inherits Claude Code's whole environment. The docs say only that Claude Code sets `CLAUDE_PROJECT_DIR` in the server's environment. [mcp] Design rule: declare everything the server needs in `env`.

### 1.4 Launch options and their prerequisites

| Launch | Server block | Prerequisites | Notes |
| :- | :- | :- | :- |
| Bundled JS file | `"command": "node", "args": ["${CLAUDE_PLUGIN_ROOT}/dist/torn.js"]` | Node.js on PATH | No download at start. Ties the block to Claude Code's variable name. |
| Bundled JS with dependencies | Same as above | Node.js on PATH, plus `package.json` and a lockfile in the plugin root | See 1.5. |
| `npx` | `"command": "npx", "args": ["-y", "@scope/torn-mcp@1.2.3"]` | Node.js and npm on PATH. The package must be on npm. | Same block works in every agent. |
| `uvx` | `"command": "uvx", "args": ["torn-mcp@1.2.3"]` | uv on PATH. The package must be on PyPI, or use `--from git+https://...`. | Same block works in every agent. `@` takes an exact version only. [uv-tools] |
| Python in the plugin | A `SessionStart` hook builds a venv in `${CLAUDE_PLUGIN_DATA}` | Python or uv on PATH | Claude Code installs no Python dependencies. [loading] |
| `.mcpb` bundle | `"mcpServers": "./servers/torn.mcpb"` | Depends on the bundle | The bundle's own `user_config` is set with **Configure** in `/plugin`. [components] |

- The docs' own `claude mcp add` example launches a server with `npx -y airtable-mcp-server`. [mcp]
- Claude Code does not install Node.js, npm, Python, or uv. The LSP section says the same rule plainly: a plugin configures the connection but does not install the server binary. [components]

### 1.5 Automatic Node.js dependency install

When Claude Code copies a plugin into the cache, it installs the plugin's Node.js dependencies there. [loading] The rules:

- The plugin root must hold `package.json` and a supported lockfile: `bun.lock`, `npm-shrinkwrap.json`, or `package-lock.json` (lockfileVersion 2 or 3). `yarn.lock` and `pnpm-lock.yaml` are skipped.
- Every dependency must be a registry package pinned to an exact version. No git dependencies.
- Install scripts do not run (`--ignore-scripts`). A native module that builds in `postinstall` will not compile.
- The install has a 60-second limit. It cannot be turned off.
- A plugin loaded in place from a local-path marketplace gets no install.
- For an `npm`-source plugin, use `npm-shrinkwrap.json`, because npm leaves `package-lock.json` out of published packages.

### 1.6 Where the plugin code can live

A marketplace entry's `source` has seven types. They are a relative path, `github`, `url`, `git-subdir`, `npm`, `archive`, and `command`. `url` takes any git URL. `git-subdir` takes one folder of another repo. `archive` takes a zip over HTTPS. [marketplace-reference] So the `torn` plugin entry in this repo's marketplace can point at server code in another repository or an npm package.

For a relative path, Claude Code must have the marketplace's files. A `github` or `git` marketplace source gives it those files. [marketplace-reference]

### 1.7 Adding the server by hand in Claude Code

`claude mcp add --transport stdio torn --env TORN_API_KEY=... -- npx -y @scope/torn-mcp` works, but the key goes into argv and shell history. [mcp]

A safer form uses expansion. In `.mcp.json` or `~/.claude.json`, write `"env": { "TORN_API_KEY": "${TORN_API_KEY}" }`. `${VAR}` and `${VAR:-default}` expand in `command`, `args`, `env`, `url`, and `headers`. An unset variable with no default is left as the literal `${VAR}` text, with a warning. [mcp]

Risk of the expansion route (inference, not stated by the docs): the key must then be in Claude Code's own environment. The Bash tool's commands probably inherit that environment. Then the model can print the key into the transcript. The plugin `userConfig` route does not have this risk.

## 2. Other agents

### 2.1 Codex CLI

- Config: a `[mcp_servers.<name>]` table in `~/.codex/config.toml` or a trusted project's `.codex/config.toml`. Fields: `command`, `args`, `env`, `env_vars`, `cwd`, `startup_timeout_sec`, `tool_timeout_sec`. [codex-mcp]
- `env_vars` lists names to forward from Codex's environment, for example `env_vars = ["TORN_API_KEY"]`. That keeps the key out of the config file. [codex-mcp]
- CLI: `codex mcp add <name> --env VAR=VALUE -- <command>`. Again the key goes into argv. [codex-mcp]
- **Unconfirmed:** whether a Codex stdio server inherits the whole parent environment. The docs do not say. [codex-mcp]
- Codex plugins: Codex finds plugin manifests at `.codex-plugin/plugin.json`, `.claude-plugin/plugin.json`, and `.cursor-plugin/plugin.json`, and Agent Plugins `plugin.json` at the root. It reads marketplaces from `.agents/plugins/marketplace.json`, `.claude-plugin/marketplace.json`, and `.cursor-plugin/marketplace.json`. [codex-src-protocol] [codex-src-marketplace]
- If a Codex plugin's server config sets no `cwd`, the server starts in the plugin root. A configured `cwd` must stay inside the plugin root. [codex-src-mcp]
- **Unconfirmed:** whether Codex expands `${CLAUDE_PLUGIN_ROOT}` or `${user_config.*}` in a plugin's MCP config. No code for it turned up in a search of the source. If Codex does not expand them, a Claude Code `.mcp.json` that uses them breaks in Codex. An `npx` or `uvx` launch avoids the root variable. The key reference still needs another plan in Codex.
- Codex plugins have no user-config prompt that this research found. [codex-mcp]

### 2.2 Cursor

- Config: `.cursor/mcp.json` in the project, or `~/.cursor/mcp.json` for all projects. A stdio server has `type: "stdio"`, `command`, `args`, `env`, and `envFile`. [cursor-mcp]
- Interpolation: `${env:NAME}`, `${userHome}`, `${workspaceFolder}`, and others, in `command`, `args`, `env`, `url`, and `headers`. [cursor-mcp]
- Cursor's advice is to keep secrets out of the file and use `${env:NAME}` or `envFile`. [cursor-mcp]
- Cursor plugins use `.cursor-plugin/plugin.json` and an `mcp.json` at the plugin root. Cursor expands `${CURSOR_PLUGIN_ROOT}`. It does not expand the Agent Plugins `${PLUGIN_ROOT}` and `${PLUGIN_DATA}`. The docs describe no config or secret prompt. [cursor-plugins]
- Programmatic registration exists as `vscode.cursor.mcp.registerServer()`, with no details. [cursor-mcp]

### 2.3 Gemini CLI

- **Surprise:** the Gemini CLI docs say Gemini CLI "was replaced by Antigravity CLI on June 18th, 2026" for unpaid tier and Google One users. [gemini-mcp] Antigravity CLI was not researched.
- Config: `mcpServers` in `settings.json`, with `command`, `args`, `env`, `cwd`, `timeout`, `trust`. `env` values expand `$VAR` and `${VAR}`. An undefined variable becomes an empty string. [gemini-mcp]
- Gemini CLI strips sensitive variables from the inherited environment. Names that match `*TOKEN*`, `*SECRET*`, `*PASSWORD*`, `*KEY*`, `*AUTH*`, and `*CREDENTIAL*` are removed. A variable set explicitly in `env` is kept. So `env` must name `TORN_API_KEY`, for example `"TORN_API_KEY": "$TORN_API_KEY"`. Otherwise the key does not reach the server. [gemini-mcp]
- CLI: `gemini mcp add -e KEY=value <name> <command> [args...]`. The key goes into argv. [gemini-mcp]
- Extensions: `gemini-extension.json` declares `mcpServers` and can use `${extensionPath}`. Extension `settings` entries have `name`, `description`, `envVar`, and `sensitive`. A sensitive value goes to the system keychain. The value reaches the server as the named environment variable. Install with `gemini extensions install <github-url>`, which needs git. [gemini-ext] This is the closest match to Claude Code's `userConfig`.

### 2.4 Agent Plugins 1.0 (cross-agent standard)

- **Surprise:** Vercel announced Agent Plugins 1.0.0 on 2026-08-06, an open format for skills plus MCP servers. Its steering committee is Amazon, Cursor, Microsoft, OpenAI, and Vercel. [agent-plugins] [vercel-changelog] Codex's source code checks for its schema. [codex-src-namespace] The spec does not mention Claude Code.
- Layout: `plugin.json` at the root (required fields `$schema` and `name`), `skills/`, and `mcp.json` at the root. MCP config cannot be inline in `plugin.json`. [agent-plugins-spec]
- `${PLUGIN_ROOT}` and `${PLUGIN_DATA}` expand in `args`, `env` values, and `cwd`, but not in `command`. [agent-plugins-spec]
- The spec defines no user-config or secret mechanism. It says `env` and `headers` are visible package data and that plugins must not put credentials there. Credential storage is left to each client. [agent-plugins-spec]
- The client picks the base environment. It can inherit, omit, or clean variables. The spec tells plugins not to rely on inherited variables. [agent-plugins-spec]

### 2.5 `npx skills add` (vercel-labs/skills)

- The CLI installs skill folders into each agent's skills directory, for example `.claude/skills/`. It supports Claude Code, Codex, Cursor, and many more agents. [skills-agents]
- It reads `.claude-plugin/marketplace.json` and `.claude-plugin/plugin.json` only to find the skills they list. [skills-creating]
- The source has no MCP install or config code. The only "mcp" text is an agent named MCPJam. [skills-src]
- So a user who installs with `npx skills add xentac/skills` gets the skills and no server. The skill text must tell that user how to add the server by hand to their own agent.

## 3. The MCP specification

- stdio: the client launches the server as a subprocess. Messages go over stdin and stdout. The server can log to stderr. It must write nothing but MCP messages to stdout. [mcp-transports]
- Authorization: the OAuth flow is for HTTP transports. A stdio implementation gets its credentials from the environment instead. [mcp-authorization] So an environment variable is the protocol's own answer for a stdio server's key.

## 4. What this means for the decisions

- **For #4 (language).** Node.js has the smoothest path in Claude Code: automatic dependency install from a lockfile, or a single bundled JS file with no dependencies. Python needs uv or a hook. Both `npx` and `uvx` launches need a runtime on the user's PATH. TypeScript and Python both support an `npx` or `uvx` launch that works the same in every agent.
- **For #5 (repo location).** The plugin entry can point at code in three places. They are this repo (relative path), another repo (`github` or `git-subdir`), and npm. This repo's `skills/` folder ships to every `npx skills add` user. So keep server code out of `skills/`.
- **For #6 (key setup).** Make the server read `TORN_API_KEY` and `FFSCOUTER_API_KEY` from its environment. That is the only mechanism every agent shares. In the Claude Code plugin, fill those variables from sensitive `userConfig`. For other agents, document `env_vars` (Codex), `${env:NAME}` or `envFile` (Cursor), and an explicit `env` entry (Gemini CLI). An optional key-file path or key command is worth a look for users who do not want the key in any environment. On Linux, Claude Code keeps a sensitive value in a plain-text file. Users who keep keys in sops will want to know this.

## Sources

All fetched 2026-10-21.

- [manifest-reference] Claude Code, Plugin manifest reference: https://code.claude.com/docs/en/plugins-reference (served as https://code.claude.com/docs/en/plugins/manifest-reference)
- [components] Claude Code, Add components to a plugin: https://code.claude.com/docs/en/plugins/components
- [loading] Claude Code, Plugin loading reference: https://code.claude.com/docs/en/plugins/loading
- [marketplace-reference] Claude Code, Marketplace reference: https://code.claude.com/docs/en/plugins/marketplace-reference
- [cli-reference] Claude Code, Plugin commands reference: https://code.claude.com/docs/en/plugins/cli-reference
- [mcp] Claude Code, MCP: https://code.claude.com/docs/en/mcp
- [settings-reference] Claude Code, Settings reference, `pluginConfigs`: https://code.claude.com/docs/en/settings-reference
- Claude Code, Troubleshoot plugins: https://code.claude.com/docs/en/plugins/troubleshooting
- [codex-mcp] OpenAI Codex, MCP: https://developers.openai.com/codex/mcp (redirects to https://learn.chatgpt.com/docs/extend/mcp?surface=cli)
- [codex-src-protocol] openai/codex at commit 17a0e6f: https://github.com/openai/codex/blob/17a0e6f63fad13f577ef87b36b4ea37fc06385e9/codex-rs/exec-server-protocol/src/protocol.rs
- [codex-src-marketplace] https://github.com/openai/codex/blob/17a0e6f63fad13f577ef87b36b4ea37fc06385e9/codex-rs/core-plugins/src/marketplace.rs
- [codex-src-mcp] https://github.com/openai/codex/blob/17a0e6f63fad13f577ef87b36b4ea37fc06385e9/codex-rs/codex-mcp/src/plugin_config.rs
- [codex-src-namespace] https://github.com/openai/codex/blob/17a0e6f63fad13f577ef87b36b4ea37fc06385e9/codex-rs/utils/plugins/src/plugin_namespace.rs
- [cursor-mcp] Cursor, MCP: https://cursor.com/docs/context/mcp
- [cursor-plugins] Cursor, Plugins: https://cursor.com/docs/plugins
- [gemini-mcp] Gemini CLI, MCP servers: https://geminicli.com/docs/tools/mcp-server/
- [gemini-ext] Gemini CLI, Extensions reference: https://geminicli.com/docs/extensions/reference/
- [agent-plugins] Agent Plugins: https://agent-plugins.org
- [agent-plugins-spec] Agent Plugins 1.0.0 specification: https://agent-plugins.org/specification
- [vercel-changelog] Vercel, Introducing Agent Plugins 1.0.0: https://vercel.com/changelog/introducing-agent-plugins-1-0-0 (seen in search results only, not fetched)
- [skills-agents] vercel-labs/skills at commit a80e4c9, docs/agents.md: https://github.com/vercel-labs/skills/blob/a80e4c9d12d607631249d4d7d059f835d4b2f13a/docs/agents.md
- [skills-creating] https://github.com/vercel-labs/skills/blob/a80e4c9d12d607631249d4d7d059f835d4b2f13a/docs/creating-skills.md
- [skills-src] https://github.com/vercel-labs/skills/blob/a80e4c9d12d607631249d4d7d059f835d4b2f13a/src/agents.ts
- [mcp-transports] MCP specification 2025-11-25, Transports: https://modelcontextprotocol.io/specification/2025-11-25/basic/transports
- [mcp-authorization] MCP specification, latest (2026-07-28), Authorization: https://modelcontextprotocol.io/specification/latest/basic/authorization
- [uv-tools] uv, Using tools: https://docs.astral.sh/uv/guides/tools/
