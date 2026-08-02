# SiteLog AI — Website Compliance Hardening Report
**Date:** 2026-08-02 · **Scope:** sitelog-ai.com static site + Supabase/Stripe billing backend
**Pattern targets:** (1) ADA/WCAG accessibility suits · (2) CIPA/wiretap tracking claims · (3) Auto-renewal law (ARL) claims

> Architecture note: the original task list assumed trial-in-Stripe-Checkout. The live product
> uses **card-at-signup** ($0 Stripe setup session) with the subscription auto-created server-side
> at the first billable seat. Tasks 3 and 6 were adapted to harden the flow that actually exists.

---

## Task 1 — Accessibility (WCAG 2.1 AA)

Applied to index, teams, dashboard, start, faq, terms, privacy, 404, accessibility:

- **Skip-to-content link** first focusable element on every page; `<main id="main">` landmark added everywhere; one `<h1>` per page verified.
- **Visible focus indicators**: 3px `#B85511` outline on `:focus-visible` for links, buttons, inputs, selects, summaries — added to every page's CSS. No outlines removed.
- **Forms**: static labels now `for`-associated (signup, dashboard gate). All dynamically generated crew-builder and dashboard inputs carry `aria-label`s. OTP inputs: `autocomplete="one-time-code"` + `inputmode="numeric"` (teams + dashboard). Status/error message regions (`#msg`, `#gMsg`) are `role="status" aria-live="polite"` so screen readers hear errors.
- **Semantic fix**: dashboard "Sign out" was a click-handler `<span>` → now a real `<button>`.
- **Mobile nav**: homepage uses a native `<details>/<summary>` disclosure menu (keyboard-operable by default), summary now `aria-label`ed. Subpages use a simple always-visible nav (no hidden menu to trap).
- **Contrast (measured, WCAG formula)**:
  | Color use | Before | After |
  |---|---|---|
  | Small orange links/text `#C25A0E` on paper | 4.19:1 ❌ | `#B85511` = **4.59:1 ✓** (site-wide) |
  | 11–13px orange labels `#E87722` on paper | 2.81:1 ❌ | `#B85511` = **4.59:1 ✓** |
  | Card-banner bold `#B85511` on `#FDF1E4` | 4.34:1 ❌ | `#7A3C00` = **7.63:1 ✓** |
  | Body/secondary/buttons/wordmark | 16.8 / 6.5 / 13.5 / 4.34(large) | unchanged ✓ |
- **Images**: all `<img>` alt text reviewed this session; screenshots carry descriptive alts (e.g. the fire-main voice-note description).
- **New page**: `accessibility.html` — WCAG 2.1 AA commitment + barrier-report channel (support@sitelog-ai.com, 5-business-day response target). Linked in every footer.
- **Tooling caveat (honest)**: Lighthouse/axe were not runnable in this environment; the audit above is a manual WCAG checklist pass with computed contrast math. Recommend a one-time browser Lighthouse run (Chrome DevTools → Lighthouse → Accessibility) to confirm ≥95; remaining risk is low.

## Task 2 — Tracking & script hygiene (CIPA)

**Third-party request inventory (after):**
| Page | Third-party requests | Purpose |
|---|---|---|
| index.html | none | — |
| teams.html | supabase.co (service provider) · photon.komoot.io (address autocomplete, **on typing only**) | auth/signup · address suggestions |
| dashboard.html | supabase.co (service provider) | auth/roster/billing |
| start / faq / terms / privacy / 404 / accessibility | none | — |

- **Removed**: jsdelivr CDN — supabase-js is now **self-hosted** (`vendor-supabase.min.js`) on both form pages.
- **Confirmed absent**: session replay, ad pixels, chat widgets, analytics of any kind, font CDNs (system font stack), non-essential cookies.
- **Cookie banner**: correctly **not added** — the site sets no non-essential cookies. A plain-language "Cookies and tracking" section was added to privacy.html instead.
- **⚠️ ATTORNEY FLAG — Photon geocoder**: as the admin types a job address in the crew builder, keystrokes in that one field go to Photon (komoot, OSM-based) for suggestions. Disclosed in privacy.html. This is the site's only third-party call from a form page besides the service providers. If counsel wants zero exposure, removing autocomplete is a one-line change (addresses would be typed manually).

## Task 3 — Trial & renewal disclosures (ARL)

- **Disclosure box** (`.arlbox`) now sits directly above the signup CTA, readable type, stating: $24.99 per billed seat/mo · 30-day free trial, card required at signup ($0 today) · first-charge timing · automatic monthly renewal until cancelled · cancel online anytime via dashboard → Manage billing · cancel in trial = pay nothing.
- **Affirmative consent**: unchecked checkbox — *"I agree to the automatic renewal terms above and to the Terms of Service and Privacy Policy."* CONTINUE is blocked until ticked.
- **Consent record**: on signup the backend stamps `companies.billing_consent_at` + `billing_consent_version` (current version `arl-2026-08-01`) — provable "what they saw and when they agreed."
- **Button text**: CTA is now **"Start 30-day free trial — then $24.99/seat/mo"** (was "CONTINUE").
- **Cancellation path**: "Manage billing / Cancel" now linked in the site footer (index + teams) and in the dashboard; portal cancellation requires no human contact.
- **Trial-end reminder**: BUILT (not just TODO — see Task 6): webhook emails the admin ~3 days pre-conversion with exact amount, date, and cancel link.

## Task 4 — Legal page alignment

- **terms.html**: new "How web billing works (automatic renewal disclosure)" paragraph before §4 — Stripe as processor, card-at-signup, trial conversion, monthly renewal, online cancellation effective end of period, refund cross-reference, **30-day price-change notice** mechanism. Effective date → Aug 1, 2026. Apple IAP language for app purchases retained.
- **privacy.html**: new "Cookies and tracking" section (no trackers / no sale / no banner rationale). Verified against actual collection: email OTP auth (no phone collection — corrected the prompt's assumption), crew names/emails, Stripe-held card data, voice/transcripts, Photon disclosure — all already accurately described. "We do not sell your data" present. Effective date → Aug 1, 2026.
- **Footers**: every page now links Terms · Privacy · Accessibility (faq/terms/privacy previously had no footer nav — added).

## Task 5 — Recording consent

- **faq.html**: new entry *"Do I need permission to record on the jobsite?"* — plain-English all-party-consent warning naming Florida and California, positions SiteLog as for the user's own dictated logs, puts legal responsibility on the user. Tagged for attorney review.
- **TODO (iOS app repo, not this site)**: add a first-run notice covering the same point. → relay to app session.

## Task 6 — Stripe configuration

**Deployed (code):**
- `team` **v32**: `setup_card` sessions now carry `custom_text[submit][message]` (renewal statement: trial, $/seat, renewal cadence, cancel-anytime-online) + `consent_collection[terms_of_service]='required'` with graceful fallback until the dashboard ToS URL is set. Signup records ARL consent (timestamp + version). Server-created subscriptions request `automatic_tax[enabled]` with graceful fallback until Stripe Tax is activated. Legacy checkout also carries the renewal statement.
- `stripe-webhook` **v13**: adds `customer.subscription.trial_will_end` → admin reminder email (exact monthly amount = seats × $24.99, end date, one-click Manage billing / Cancel). Existing: signature verification on every event (unsigned POST → 400, verified live), payment-failed 14-day notice, read-only notice, status/seat sync, setup-mode card capture.
- Notes on prompt items intentionally N/A under card-at-signup: `trial_settings.end_behavior.missing_payment_method` (a sub is never created without a saved card) and `payment_method_collection:'always'` (setup mode *is* the card collection).

**Manual Dashboard steps** → see `stripe-dashboard-checklist.md`. The one blocking item: **add `customer.subscription.trial_will_end` to the webhook endpoint's selected events** (currently 6, needs 7) — the reminder email can't fire until then.

## Attorney-review locations (`<!-- ATTORNEY REVIEW -->`)
1. `teams.html` — ARL disclosure box + consent checkbox (v `arl-2026-08-01`)
2. `terms.html` — "How web billing works" auto-renewal subsection
3. `privacy.html` — "Cookies and tracking" section
4. `faq.html` — jobsite recording-consent entry
5. `functions/team/index.ts` — RENEWAL_STATEMENT shown on the Stripe card page
6. `functions/stripe-webhook/index.ts` — trial-ending reminder email copy
7. `stripe-dashboard-checklist.md` — Stripe Tax registration obligations

## Open items / recommendations
1. **You**: complete `stripe-dashboard-checklist.md` (item 1 — the webhook event — is the only functional blocker).
2. **You**: one browser Lighthouse accessibility run to confirm scores (expected ≥95).
3. **Attorney**: review the 7 tagged locations; decide on Photon autocomplete (keep-with-disclosure vs remove).
4. **App session**: iOS first-run recording notice; sync team v32 / webhook v13 before any redeploy.
5. **When revenue starts**: activate Stripe Tax + review state registrations with your accountant.
