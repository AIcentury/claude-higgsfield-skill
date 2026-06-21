# Finish the "Red Panda" test prompt

This folder finishes a task that was started in a Claude Code web session:
generate a test image with **Higgsfield (Nano Banana 2)** and create a prompt
in the **AI Century Prompt Library** at https://aicenturies.com.

The image was generated successfully. The publish step could **not** run from
the web session because that sandbox's network policy blocks outbound calls to
`aicenturies.com` and the image CDN. So it's captured here to run once from any
computer that has the handoff `.env`.

## The generated image
- **Model:** `nano_banana_2` (Google, via Higgsfield)
- **Dimensions:** 1792 × 2400 (2K, 3:4)
- **URL:** https://d8j0ntlcm91z4.cloudfront.net/user_3BmuvRH5LPeeHs0w11PXepLS78N/hf_20260621_152346_5c77e07f-e92e-4798-a110-75ad87400fa0.png

## How to finish it (2 minutes, any computer)

1. Copy your handoff **`.env`** into this folder (it holds `WP_SITE`,
   `WP_USER`, `WP_APP_PASSWORD`). **Do not commit it.**
2. Run:
   ```bash
   bash finish-publish.sh
   ```
3. The script ingests the image and creates the prompt as **pending**, then
   prints an `editUrl`. Open it in wp-admin, review, and click **Publish**.

## Notes
- The Agent API **never publishes** — everything lands as `pending` by design
  (the `claude-uploader` account has no publish capability). You publish.
- Your WordPress server fetches the image from the CDN itself, so you don't
  need the image bytes locally.
- `category` and `model` in the script (`Portrait`, `Nano Banana 2`) should
  match the real terms returned by `GET /agent/context`. The script saves that
  response to `/tmp/aicpl_context.json` so you can check the exact slugs.

## Alternative: let Claude do it from the web
If you add `aicenturies.com` to your web environment's **network egress
allowlist** and start a **new** session, Claude can run all of this for you —
no computer needed. The allowlist change only applies to *new* sessions.
