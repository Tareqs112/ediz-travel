# Admin Mobile UX Plan

## Current Problems

### Critical (breaks mobile entirely)
1. **Fixed sidebar** — `w-64` always renders. At 390px it consumes 64% of the viewport, leaving ~130px for content. The main content area is completely unusable.
2. **Desktop header** — `px-8` header is not adapted for small screens; title and user controls crowd together.
3. **Drivers index** — Pure `<table>` with 5 columns + `whitespace-nowrap`. Causes full horizontal overflow on all mobile widths.
4. **Vehicles index** — Same. Six columns overflow on mobile.

### Significant
5. **Operations date bar** — Prev/Today/Next + date input wrap poorly below 390px.
6. **Summary stat bar** — 6 stat boxes render 2-up (3 rows), pushing services below the fold on mobile.
7. **Service cards** — Already `flex-col md:flex-row` (good), but "Edit/Assign" button at bottom has no enforced touch target width.
8. **Availability page** — Structurally fine once sidebar fixed; no changes needed.

### Minor
9. Table action links (View/Edit/Delete) lack minimum touch target height.
10. Admin header (`h-16`) wastes 64px of vertical mobile space permanently.

---

## Proposed Changes

### 1. Admin Layout — Sidebar Toggle
- Add a hamburger button (mobile-only) in the header.
- Sidebar collapses off-screen (`-translate-x-full`) on mobile by default, slide in/out via Stimulus.
- Overlay backdrop closes it on tap.
- **No desktop change** — sidebar stays fixed at `md+`.

### 2. Operations Index
- Date bar: single `flex-wrap gap-2` row; Prev/Today/Next + date field all on one line, wrapping gracefully.
- Stats: `grid-cols-3 md:grid-cols-6` with compact `p-2 md:p-4` — shows all 6 in 2 rows at mobile.
- Service cards: `p-3 sm:p-5`; "Edit/Assign" full-width on mobile, inline on desktop.

### 3. Drivers Index
- Mobile: card list (`md:hidden`), showing Name+External badge, Status, Phone (tap-to-call), Today's services.
- Desktop: original table (`hidden md:block`). Unchanged.

### 4. Vehicles Index
- Same dual-mode approach: card list on mobile, table on desktop.

### 5. Availability
- Inherits fix from sidebar; layout already collapses to 1 column on mobile. No changes needed.

---

## Screens NOT Changed
- Trip Services form (already single-column)
- Driver/Vehicle show and edit forms (already responsive)
- Booking, Customer, Inquiry pages (out of scope)
- Public website (not touched)
