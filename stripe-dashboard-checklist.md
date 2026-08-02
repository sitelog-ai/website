# Stripe Dashboard Checklist — manual steps for Lou

Everything code-side is deployed (team fn v32, stripe-webhook v13). These items live in
the Stripe Dashboard and only you can click them. All in **live mode** (no Test banner).

## 1. REQUIRED — add the trial-reminder event to the webhook  ⚠️ do this one first
The trial-ending reminder email can't fire until Stripe sends us the event.
- https://dashboard.stripe.com/webhooks → open the endpoint **charismatic-radiance**
  (`https://smogomdqivzomyggxlur.supabase.co/functions/v1/stripe-webhook`)
- **Edit destination** → add event: **`customer.subscription.trial_will_end`**
- Save. "Listening to" should now read **7 events**.

## 2. REQUIRED — Terms of Service + Privacy Policy URLs (enables the ToS checkbox on the card page)
- https://dashboard.stripe.com/settings/public → **Public business information**
- Set **Terms of service URL**: `https://sitelog-ai.com/terms.html`
- Set **Privacy policy URL**: `https://sitelog-ai.com/privacy.html`
- Until these are set, the card page shows the renewal statement but skips Stripe's
  native ToS checkbox (the code falls back gracefully — our own signup checkbox still covers consent).

## 3. REQUIRED — statement descriptor
- https://dashboard.stripe.com/settings/public (same page)
- **Statement descriptor**: `SITELOGAI` (unrecognized descriptors are the #1 chargeback driver)
- Shortened descriptor: `SITELOG`

## 4. Customer emails (Stripe sends these for you)
- https://dashboard.stripe.com/settings/emails
- Turn ON: **Successful payments (receipts)**
- Turn ON: **Refunds**
- https://dashboard.stripe.com/settings/billing/subscriptions →
  - Turn ON: **Send a reminder email 7 days before a trial ends** (you saw this toggle earlier —
    flip it on; it complements our own 3-day reminder)
  - Under "Manage failed payments": already verified set — Smart Retries + **mark subscription
    as unpaid** when retries fail. Also turn ON **failed-payment emails to customers** if shown.

## 5. Stripe Tax  <!-- ATTORNEY REVIEW -->
- https://dashboard.stripe.com/settings/tax → **Activate Stripe Tax**
- The code already requests `automatic_tax` on every subscription and falls back cleanly
  if Tax isn't active — activating it makes tax collection real.
- ⚠️ Merchant obligation Stripe does NOT discharge: review **Registrations** (Stripe Tax →
  Registrations) as revenue grows. SaaS is taxable in a number of US states; Stripe
  monitors your nexus thresholds and shows warnings, but registering is on you.
  Discuss with your accountant once real revenue starts.

## 6. Billing portal settings (the "cancel without talking to a human" requirement)
- https://dashboard.stripe.com/settings/billing/portal
- Ensure ON: **Cancel subscriptions** — set to cancel **at end of billing period**
- Ensure ON: **Update payment methods**
- Ensure ON: **Invoice history**
- Leave OFF: **Update quantities** (seats are derived automatically by the app — manual
  quantity edits in the portal would fight the roster; the app re-syncs on next change anyway)

## 7. Radar (fraud) — confirm only
- https://dashboard.stripe.com/settings/radar — Radar is on by default for standard
  accounts; just confirm it's active. No rules changes needed at this size.

## Done already (no action)
- ✅ Live keys in Supabase, live $24.99 price, webhook signature verification
- ✅ Dunning: Smart Retries ~2 weeks → subscription marked **unpaid** → app flips team read-only
- ✅ Card at signup ($0 setup session), subscription auto-starts at first billable seat
