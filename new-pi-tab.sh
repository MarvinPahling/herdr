#!/bin/sh
set -eu

workspace_id=${HERDR_WORKSPACE_ID:-}
if [ -z "$workspace_id" ]; then
  echo "Cannot create a Pi tab without Herdr workspace context." >&2
  exit 1
fi

create_result=$(herdr tab create --workspace "$workspace_id" --cwd "$PWD" --focus)
pane_id=$(printf '%s\n' "$create_result" | python3 -c '
import json
import sys

result = json.load(sys.stdin)["result"]
root_pane = result["root_pane"]
pane_id = root_pane if isinstance(root_pane, str) else root_pane.get("pane_id")
if not pane_id:
    raise SystemExit("tab create response did not include a root pane ID")
print(pane_id)
')

agent_name="pi-$(date +%s)-$$"
herdr agent start "$agent_name" --kind pi --pane "$pane_id"
