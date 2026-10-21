# xentac/skills

Agent skills for Torn City and FF Scouter, plus the MCP servers that give those skills live API access.

## Torn API keys

**Access level**:
The fixed permission tier of a Torn API key: Public, Minimal, Limited, or Full.
_Avoid_: permission level, key level, key type

**Custom key**:
A Torn API key that the owner builds from chosen selections instead of a fixed access level.
_Avoid_: custom-level key

**Key label**:
The name that a user gives one Torn API key, so that a tool or a message can refer to the key without its value. A key at a fixed access level can omit the label and is then known by its level name.
_Avoid_: key name, key alias, key id

**Disclosure table**:
The five-column statement that Torn's API Terms of Service require wherever a user enters a key: data storage, data sharing, purpose of use, key storage and sharing, and key access level.
_Avoid_: privacy notice, ToS table

## Rate limits

**Request budget**:
The share of an API rate limit that the MCP servers on one machine allow themselves. The rest stays free for the user's other tools.
_Avoid_: quota, allowance, rate limit (for the servers' share)
