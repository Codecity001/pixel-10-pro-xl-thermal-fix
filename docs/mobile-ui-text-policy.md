# Mobile UI text policy

Visible Magisk/KSU installer and Action text should fit narrow phone screens.

Rules:
- Soft target: 38-42 characters.
- Hard target for literal UI text: 44 characters.
- One fact per line.
- Avoid semicolon chains and long combined lines.
- Use `Settings`, not `Cycle`, for user-facing menus.
- Long technical details belong in logs/debug ZIPs, not the manager view.


## Action navigation policy

- Action root menu must expose `Back`.
- Settings menu must expose `Back`.
- Completed actions must return to the parent menu.
- Debug ZIP creation must show status/progress before work starts.


## Manager description policy

- Combine each Ampel with its active value.
- Preferred format:
  `P:🟢 mod | T:🟢 outdoor-ext | Z:🟢 100p | Action: settings/debug`
- Keep it wrap-friendly rather than using literal multiline `module.prop`.
