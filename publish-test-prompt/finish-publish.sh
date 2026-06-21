#!/usr/bin/env bash
#
# finish-publish.sh — Create the "red panda" TEST prompt in the AI Century
# Prompt Library via the plugin's Agent API.
#
# WHY THIS EXISTS
# ---------------
# The image was already generated with Higgsfield (model: nano_banana_2).
# The remote Claude Code sandbox could not reach aicenturies.com (network
# egress allowlist), so the create step is captured here to run from any
# machine that has the handoff `.env` (WP_SITE / WP_USER / WP_APP_PASSWORD).
#
# The Agent API only ever creates *pending* content — you still click
# Publish in wp-admin. Your WordPress server fetches the image itself from
# the CDN (source_url ingest), so you do NOT need the image bytes locally.
#
# USAGE
# -----
#   1) Put your handoff `.env` next to this script (same folder), or export
#      WP_SITE / WP_USER / WP_APP_PASSWORD in your shell.
#   2) bash finish-publish.sh
#   3) Open the returned editUrl in wp-admin, review, and Publish.
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Load credentials from .env if present (never commit the .env) ---------
if [[ -f "$HERE/.env" ]]; then
  WP_SITE="${WP_SITE:-$(grep '^WP_SITE=' "$HERE/.env" | cut -d= -f2- | sed 's#/*$##')}"
  WP_USER="${WP_USER:-$(grep '^WP_USER=' "$HERE/.env" | cut -d= -f2-)}"
  WP_APP_PASSWORD="${WP_APP_PASSWORD:-$(grep '^WP_APP_PASSWORD=' "$HERE/.env" | cut -d= -f2- | tr -d ' ')}"
fi

: "${WP_SITE:?Set WP_SITE (e.g. https://aicenturies.com) or provide a .env}"
: "${WP_USER:?Set WP_USER (the login email) or provide a .env}"
: "${WP_APP_PASSWORD:?Set WP_APP_PASSWORD (24-char application password) or provide a .env}"

WP="${WP_SITE%/}/wp-json/aicpl/v1"
AUTH=(-u "$WP_USER:$WP_APP_PASSWORD")

# --- The generated test image (Higgsfield / nano_banana_2) -----------------
IMG="https://d8j0ntlcm91z4.cloudfront.net/user_3BmuvRH5LPeeHs0w11PXepLS78N/hf_20260621_152346_5c77e07f-e92e-4798-a110-75ad87400fa0.png"
IMG_W=1792
IMG_H=2400

uuid() { command -v uuidgen >/dev/null 2>&1 && uuidgen || cat /proc/sys/kernel/random/uuid; }

echo "==> 0) Sanity: read context (your real categories / models / tags)"
curl -fsS "${AUTH[@]}" "$WP/agent/context" > /tmp/aicpl_context.json \
  && echo "    OK — connected. (saved to /tmp/aicpl_context.json)" \
  || { echo "    FAILED to reach $WP/agent/context — check .env / allowlist"; exit 1; }

echo "==> 1) Ingest the finished image (your server pulls it from the CDN)"
MEDIA="$(curl -fsS "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: $(uuid)" -X POST "$WP/agent/media" \
  -d "{\"source_url\":\"$IMG\",\"width\":$IMG_W,\"height\":$IMG_H}")"
echo "    $MEDIA"
COVER_ID="$(printf '%s' "$MEDIA" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)"
[[ -n "${COVER_ID:-}" ]] || { echo "    Could not parse media id"; exit 1; }
echo "    cover_id=$COVER_ID"

echo "==> 2) Create the prompt (lands as PENDING for your review)"
# NOTE: category/model below should match terms returned by /agent/context.
# Adjust if your taxonomy uses different labels/slugs.
curl -fsS "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: $(uuid)" -X POST "$WP/agent/prompt" \
  -d "{
    \"title\":\"Cozy Library Red Panda — Golden Hour Portrait\",
    \"prompts\":[\"A cinematic golden-hour portrait of a red panda wearing tiny round glasses, reading a small book in a cozy wooden library, warm volumetric light, soft bokeh, 85mm lens, photorealistic, ultra detailed\"],
    \"type\":\"image\",
    \"ratio\":\"3/4\",
    \"category\":\"Portrait\",
    \"model\":\"Nano Banana 2\",
    \"tags\":[\"red panda\",\"portrait\",\"cinematic\",\"golden hour\",\"cozy\"],
    \"cover_id\":$COVER_ID,
    \"author_label\":\"AI Century\"
  }"
echo
echo "==> Done. Open the editUrl above in wp-admin to review and Publish."
