# Design System: Midnight Tavern Editorial

## 1. Overview & Creative North Star
**The Creative North Star: "The Sommelier’s Ledger"**

This design system moves away from the sterile, utilitarian nature of typical utility apps. Instead, it adopts the persona of a high-end, cinematic experience—imagine a leather-bound ledger resting on a mahogany bar under the glow of a single Edison bulb. We are creating an interface that feels reflective, sophisticated, and slightly mysterious.

To break the "standard app" feel, this system leans into **intentional asymmetry** and **tonal depth**. We eschew rigid grids in favor of overlapping elements and varying typographic scales that feel more like a premium lifestyle magazine than a calculator. The goal is to make the user feel like they are interacting with a curated object, not just a set of data points.

---

## 2. Colors & Surface Philosophy
The palette is rooted in the "Midnight Tavern" aesthetic: deep, fermented browns, glowing ambers, and bruised reds.

### The Color Tokens
*   **Background (Primary):** `#161310` (Surface) — A near-black brown that provides a warm, infinite depth.
*   **Highlights (Primary):** `#ffb960` (Primary) to `#c8862a` (Primary Container) — The glow of aged whiskey.
*   **Warnings (Tertiary):** `#8b1a2b` (On-Tertiary-Fixed-Variant) — A deep wine red for cautionary states.
*   **Primary Text:** `#f0e6d3` (On-Surface) — A creamy, vintage paper white.

### The "No-Line" Rule
**Prohibit 1px solid borders for sectioning.** Boundaries must be defined solely through background color shifts or subtle tonal transitions. To separate a section, transition from `surface` to `surface-container-low`. The eye should perceive a change in depth, not a mechanical line.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like stacked sheets of smoked glass.
*   **Base:** `surface` (#161310)
*   **Sectioning:** `surface-container-low` (#1e1b18)
*   **Interactive Cards:** `surface-container` (#231f1c)
*   **Floating Elements:** `surface-container-highest` (#383431)

### The Glass & Gradient Rule
To achieve the "Cinematic" feel, use **Glassmorphism** for all primary data cards. 
*   **Style:** Apply `surface-variant` at 40% opacity with a `20px` backdrop-blur. 
*   **Soul:** Use a subtle radial gradient on the primary background, centered behind the main BAC metric, transitioning from `primary-container` (at 10% opacity) to `surface`. This creates a "soft amber glow" that feels like light reflecting through a glass of bourbon.

---

## 3. Typography
The typography is a dialogue between the classic (Serif) and the technical (Monospace).

*   **Display & Headlines (Newsreader/Serif):** These are our "Editorial" voices. Use `display-lg` for the main BAC number. The serif evokes history, storytelling, and wisdom.
*   **Data & Metrics (Space Grotesk/Monospace):** All changing numerical data—time remaining, drink count, percentages—must use `label-md` or `label-sm`. This provides a functional, precise contrast to the romantic headlines.
*   **Body (Manrope/Sans):** Used for instructional text (`body-md`). It is clean and legible, ensuring the "Sophisticated" feel doesn't compromise usability.

---

## 4. Elevation & Depth
In this system, elevation is a property of light and opacity, not structural shadows.

*   **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` section to create a "sunken" effect for inputs, while using `surface-container-highest` for "raised" action items.
*   **Ambient Shadows:** For floating modals, use a shadow with a `40px` blur, `0%` spread, and `#000000` at `15%` opacity. The shadow should feel like an ambient occlusion, not a drop shadow.
*   **The "Ghost Border" Fallback:** If a tactile edge is required for accessibility, use a `1px` stroke of `outline-variant` at `15%` opacity. It should be felt, not seen.
*   **Tactile Roundedness:** Use `xl` (1.5rem) for main containers to give them a "smooth-worn stone" feel. Use `md` (0.75rem) for internal interactive elements.

---

## 5. Components

### The "Druk" Hero Metric (Custom Component)
The central BAC display. Use `display-lg` in `primary` (#ffb960). It should sit atop a glassmorphic card with a subtle `2px` top-inner-glow (a gradient stroke from `primary` at 30% to transparent).

### Buttons
*   **Primary (The Amber Pour):** A pill-shaped (`full` roundedness) button using a vertical gradient from `#ffb960` to `#c8862a`. Use `on-primary` (dark brown) for text to maintain high contrast.
*   **Secondary (The Ghost):** No background fill. Use the "Ghost Border" (15% opacity `outline`) with `primary` colored text.

### Inputs (The Vessel)
Text and numerical inputs should not have a bottom line. They should be "wells"—recessed containers using `surface-container-lowest` with a `1.5rem` corner radius. 

### Cards & Lists
**Forbid the use of divider lines.** Separate list items using `16px` of vertical whitespace. If the list is dense, use alternating background tints (e.g., even rows use `surface-container-low`, odd rows are transparent).

### Selection Chips
Small, tactile "stones." Use `surface-container-high` for unselected and `primary` with 20% opacity for selected states.

---

## 6. Do's and Don'ts

### Do:
*   **Do** use wide margins. Let the content breathe like a luxury menu.
*   **Do** use "Editorial Asymmetry." For example, left-align your headlines but right-align your Monospace data points to create a dynamic visual tension.
*   **Do** use the `tertiary-container` (#f16771) sparingly. It is a "warning" light; if it’s everywhere, it loses its cinematic impact.

### Don't:
*   **Don’t** use pure white (#FFFFFF). It will shatter the "Midnight Tavern" atmosphere. Always use `on-surface` (#F0E6D3).
*   **Don’t** use harsh animations. Transitions should be slow "fades" (300ms+) rather than "snaps," mimicking the slow movement of liquids.
*   **Don’t** use standard Material icons if possible. Opt for thin-stroke (light weight) custom icons that feel hand-drawn or etched.

---
*End of Document*