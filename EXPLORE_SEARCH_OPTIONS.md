# Explore Page — Search Options & Filters (APK-style)

This document lists all **search options** and **filters** under **Bride/Groom (Matrimony)**, **Family Directory**, and **Social Workers** as implemented in the app.

---

## 1. Matrimony (Bride / Groom)

### On Explore page
- **Search Groom** — Opens “Search Grooms” flow (pay → list of grooms with search/filters).
- **Search Bride** — Opens “Search Brides” flow (pay → list of brides with search/filters).

### After tapping Search Groom or Search Bride (MatrimonySearchScreen)
- **Register as Groom / Register as Bride** — Pay ₹2100 → open registration form.
- **Search Grooms / Search Brides** — Pay ₹2100 → open list with search and filters.
- **Register as Bride instead / Register as Groom instead** — Switch to the other type.

### On Matrimony List screen (after payment)
- **Search (text)** — Live search by: **name**, **education**, **occupation**, **city**.
- **Filters**
  - **City / शहर** — Dropdown: Pune, Mumbai, Nagpur, Nashik, Kolhapur, Sangli, Other.
  - **Subcaste / पोटजात** — Dropdown: Daivadnya, Gomantak Daivajna, Konkanasth Daivajna, Kanara Daivajna, Halyal, Other.
  - **Filter icon (app bar)** — Opens bottom sheet with same City & Subcaste options.
  - **Clear filters** — Resets search text and both dropdowns.

---

## 2. Family Directory

### On Explore page
- **Family Directory** card — Subtitle: **“Search & Register”**. Tap → Family Directory screen (pay gate).

### On Family Directory screen (before/after payment)
- **Register Family / कुटुंब नोंदणी करा** — Pay ₹101 → open registration form.
- **Search Family Directory** — Tap search field → Pay ₹101 → open list with search and filters.
- **Pay Now** — Pay ₹101 for access.

### On Family Directory List screen (after payment)
- **Search (text)** — Live search by: **name**, **relation**, **village**, **contact**.
- **Filters**
  - **Village / City / गाव** — Dropdown: Pune, Mumbai, Nagpur, Nashik, Kolhapur, Sangli, Other.
  - **Relation / नाते** — Dropdown: Father, Mother, Sibling, Spouse, Grandparent, Other.
  - **Filter icon (app bar)** — Opens bottom sheet with same Village & Relation options.
  - **Clear filters** — Resets search text and both dropdowns.

---

## 3. Social Workers

### On Explore page
- **Social Workers** card — Subtitle: **“Register as a community social worker”**. Tap → Social Workers screen (search + register on same screen).

### On Social Workers screen
- **Register as Social Worker / समाजसेवक म्हणून नोंदणी करा** — Opens terms → registration form (no payment).
- **Search (text)** — Live search by: **name**, **phone**, **email**, **specialization**, **organization**, **address**.
- **Filters**
  - **Location / स्थान** — Dropdown: Pune, Mumbai, Nagpur, Nashik, Kolhapur, Sangli, Other.
  - **Subcaste / पोटजात** — Dropdown: Daivadnya, Gomantak Daivajna, Konkanasth Daivajna, Kanara Daivajna, Halyal, Other.
  - **Filter icon (app bar)** — Opens bottom sheet with same Location & Subcaste options.
  - **Clear filters** — Resets search text and both dropdowns.

---

## Summary table

| Section           | Explore entry              | Search options on next screen(s)                    | Filter options                                              |
|------------------|----------------------------|-----------------------------------------------------|-------------------------------------------------------------|
| **Matrimony**    | Search Groom, Search Bride | Search Grooms / Search Brides (after payment)       | City, Subcaste (Daivadnya, Gomantak, Konkanasth, Kanara, Halyal, Other); Filter sheet; Clear filters                 |
| **Family Directory** | Search & Register (card)   | Search Family Directory (after payment)            | Village/City, Relation; Filter sheet; Clear filters         |
| **Social Workers**   | Search & Register (card)   | Search field + filters on same screen              | Location, Subcaste (Daivadnya, Gomantak, Konkanasth, Kanara, Halyal, Other); Filter sheet; Clear filters             |

All three use:
- A **search text field** (live filter on list).
- **Two dropdown filters** (different fields per section).
- **Filter icon** in the app bar opening a **bottom sheet** with the same filter options.
- **Clear filters** to reset search and dropdowns.
