# SiteLog AI — Teams-First Rebuild Plan

**Date:** 2026-08-01 · **Goal:** deployable-today, Teams-first B2B site, zero placeholders.

> Note: the referenced `sitelog-ai-website-evaluation.md` was not present in the repo at build
> time. Per the operator's decision, this plan evaluates the **prompt's own change list**
> (which is a complete spec) rather than a document that couldn't be read. Every claim below was
> verified against the actual repo files, not memory.

## 1. Agree / Disagree on the prompt's change list

| # | Change | Verdict | Reasoning |
|---|--------|---------|-----------|
| 1 | Invert funnel — Teams-primary hero/nav/final CTA | **AGREE** | Every primary CTA currently sells the individual plan, which is not purchasable (app pre-launch). Teams is live. This is the single highest-impact fix. |
| 2 | Individual → working waitlist email capture into Supabase `waitlist` (insert-only RLS) | **AGREE** | Turns a dead end into a real asset. Insert-only anon RLS is the correct, safe shape. |
| 3 | Rebuild teams.html into full B2B landing (founder, ownership, adoption proof, ROI, dashboard mockup, owner FAQ) above the untouched signup | **AGREE** | teams.html is currently 3 cards + form. The buyer needs the full argument before the ask. Signup JS preserved byte-for-byte. |
| 4 | Founder trust block, text-only, signed-statement style | **AGREE/MODIFY** | Agree it's the pre-launch social proof. Modify: keep it genuinely short — one paragraph in his voice — and put it on **both** pages. |
| 5 | Trim homepage 25–30%, merge repeated args | **AGREE** | Verified bloat: "30 seconds" ×5, rewrite/incorruptible claims ×7. Manifesto+Compare and Reports+Record are genuinely redundant. |
| 6 | Add mechanism sentence to "can't rewrite" | **AGREE** | Source exists (faq.html: sealed overnight, tamper-evident, no edit by design). Strengthens the strongest claim. |
| 7 | Drop s06 everywhere; Vault once via s07; no dup screenshots | **AGREE** | **Verified visually:** s06 shows "28 questions left today" (a limit marketing never mentions). s07 shows the SHARE PDF/EMAIL REPORT bar and no quota. s01/s06/s07 are the same Vault list. |
| 8 | Fix s07 crop (Share bar at bottom cut by object-position:top) | **AGREE** | **Verified:** the SHARE PDF bar sits in the bottom ~25% of the 828px image; a 600px `cover/top` frame crops it. Needs per-image object-position or taller frame. |
| 9 | Real committed og-card.png (1200×630) SVG→PNG | **AGREE, with fallback** | Will build the SVG and attempt render (rsvg/chromium). If rendering is impossible in-env, fall back to an existing landscape-safe asset (report-sample.png / a composed card) — never a broken ref, never a raw portrait. |
| 10 | Mobile nav below 760px (dependency-free) | **AGREE** | Confirmed `.nav-links{display:none}` with no fallback. `<details>` disclosure pattern, no JS framework. |
| 11 | "daily log" search language in title/meta/1× on-page | **AGREE** | Confirmed 0 occurrences of "daily log" site-wide. Real SEO gap. |
| 12 | CSS cleanup — rename `--black` (holds paper), remove `.fadeband` + dead dark tokens, reserve 900 weight for h1/h2 | **AGREE/MODIFY** | Agree on removing `.fadeband` (dead) and fixing weights. Modify on `--black`: it's referenced ~100× across 3 files; a rename is high-risk churn for a cosmetic naming issue. Will alias it (`--paper` added, `--black` kept pointing at same value) so new code reads clean without a risky sweep. Documented, not silently skipped. |
| 13 | "uncorruptable" → "incorruptible" in JSON-LD | **AGREE** | Confirmed ×1 in schema. Trivial correctness fix. |
| 14 | No analytics snippet; note for later | **AGREE** | Nothing dormant ships. Deferred item below. |
| 15 | 2-seat minimum on the Teams pricing card | **AGREE** | Currently only disclosed in the signup tally. Belongs on the price. |

## 2. Factual flags (things the prompt got right, verified)

- s06 quota counter: **TRUE** (verified pixel-level).
- s07 Share bar crop risk: **TRUE** (Share bar in bottom quarter of image).
- "daily log" absent: **TRUE** (0 occurrences).
- `--black` holds `#FAF9F5`: **TRUE**.
- `.fadeband` is dead: **TRUE** (defined, no remaining HTML user after the all-light conversion).
- Signup logic to preserve: teams.html lines 204–399 (Supabase OTP → crew builder → `team` edge fn → Stripe `checkout`). Left untouched.

## 3. Execution order (by conversion impact)

1. Supabase `waitlist` table + insert-only RLS migration.
2. Homepage funnel inversion + individual→waitlist capture + pricing reorder + 2-seat disclosure.
3. teams.html B2B rebuild (all sections above the untouched signup).
4. Homepage trim / merges / claim-dedupe / mechanism sentence / screenshot curation / crop fix.
5. og-card.png, mobile nav, meta/title "daily log", CSS cleanup, incorruptible fix.
6. Verify against acceptance checklist; commit in logical chunks.

## 4. Deferred — for Louis (these live ONLY here, never on a page)

- **Founder photo** — the trust block ships text-only/signed-statement; a real headshot would lift it.
- **Fresh Vault screenshot without the quota counter** — so the Vault can be shown without dodging s06.
- **Analytics** — add Plausible or Fathom once Louis provides the domain config; nothing shipped now.
- **RLS audit before paid traffic** — review row-level security on every table the public anon key touches: `users`, `companies`/teams, `company_members`, `projects`, and the new `waitlist`. The anon key is public by design; RLS is the only thing protecting these tables.
- **Live-mode Stripe** — all Stripe objects are currently test-mode; needs live price + live keys before real revenue.
