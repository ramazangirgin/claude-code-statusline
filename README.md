# Claude Code status line

A [Claude Code](https://code.claude.com) status line that shows the model, the context usage and your
subscription rate limits with the time each one resets:

```
[Opus 5.5] ctx: 34% | 5h: 24% (resets 23:56) | 7d: 41% (resets Thu 22 Oct 09:16)
```

- **ctx** – how much of the context window the conversation uses.
- **5h** – how much of the rolling 5-hour limit you have used, and when it resets.
- **7d** – how much of the weekly limit you have used, and when it resets.

The reset time is shown in your local time zone, with the day added when it is not today.

Each limit is coloured by how much of it is **left**:

| Left        | Used (shown) | Colour |
|-------------|--------------|--------|
| under 20%   | over 80%     | red    |
| under 40%   | over 60%     | yellow |
| 40% or more | 60% or less  | green  |

## Requirements

- Claude Code with a claude.ai **Pro or Max** subscription. Claude Code sends the rate limits to the status line
  only for subscribers, and only after the first response in a session; until then the line shows the model alone.
- `bash` and [`jq`](https://jqlang.org) (`brew install jq` on macOS).
- macOS. The script formats the reset time with BSD `date -r`; on Linux, replace `date -r "$ts"` with
  `date -d "@$ts"` in `fmt_reset`.

## Activate it

1. Download the script and make it executable:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/ramazangirgin/claude-code-statusline/main/statusline.sh \
     -o ~/.claude/statusline.sh
   chmod +x ~/.claude/statusline.sh
   ```

2. Add the `statusLine` setting to `~/.claude/settings.json` (create the file if it does not exist):

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "~/.claude/statusline.sh"
     }
   }
   ```

   If the file already has other settings, add the `statusLine` key next to them. With `jq`:

   ```bash
   cp ~/.claude/settings.json ~/.claude/settings.json.bak
   jq '.statusLine = {"type": "command", "command": "~/.claude/statusline.sh"}' \
     ~/.claude/settings.json.bak > ~/.claude/settings.json
   ```

3. Start a new Claude Code session, or send a message in the current one. The status line appears above the
   prompt; the rate limits appear after Claude's first response.

## Try it without Claude Code

The script reads Claude Code's session JSON on stdin, so you can feed it sample data:

```bash
now=$(date +%s)
echo "{\"model\":{\"display_name\":\"Opus 5.5\"},\"context_window\":{\"used_percentage\":34.2},
  \"rate_limits\":{\"five_hour\":{\"used_percentage\":23.5,\"resets_at\":$((now + 7200))},
  \"seven_day\":{\"used_percentage\":85,\"resets_at\":$((now + 300000))}}}" | ~/.claude/statusline.sh
```

## Deactivate it

Remove the `statusLine` key from `~/.claude/settings.json`.

See the [status line documentation](https://code.claude.com/docs/en/statusline) for every field Claude Code passes
to the script.
