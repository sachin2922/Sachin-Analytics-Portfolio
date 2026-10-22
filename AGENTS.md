# Repository Development & Visualization Guidelines

This repository contains executive-tier commercial data analytics and SQL projects. All contributors and AI agents must adhere to the following quality standards:

---

### 1. Executive Chart Aesthetics & Palette
* **Background Theme:** Consistent dark theme (`#0B0F19` figure background, `#111827` axes background, `#1F2937` card/legend background).
* **Typography:** Clean sans-serif (`Segoe UI`, `DejaVu Sans`, `Arial`). Bold weights for titles (`13.5`–`14.5pt`) and KPIs (`20`–`24pt`).
* **Palette Tokens:**
  * Primary Green / Positive / Won: `#10B981`
  * Primary Blue / SLA / Neutral: `#3B82F6`
  * Red / Critical / Lost: `#EF4444`
  * Amber / Warning / Moderate: `#F59E0B`
  * Purple / Closed ARR: `#6366F1`
  * Quota Target / Benchmarks: `#4B5563`
  * High-Contrast Text: `#F8FAFC` (primary), `#9CA3AF` (muted secondary).

---

### 2. Donut & Pie Chart Geometry Protocol
* **Ring Thickness:** Minimum width ratio $W / R \ge 0.48$ ($W \ge 0.40$ for $R = 0.85$). Thin rings crowd text and cause font spillover.
* **Label Centering Formula:** Data labels inside donut curved bars must be mathematically positioned at the radial centerline:
  $$\text{pctdistance} = 1 - \frac{\text{width}}{2 \times \text{radius}}$$
* **No Wedge Gaps:** Strictly forbid `explode` on donuts. Maintain continuous, unified rings separated only by subtle `edgecolor='#0B0F19', linewidth=2.5`.

---

### 3. Canvas Margins, Headroom & Anti-Clipping
* **Canvas Margins:** In `GridSpec` or `subplots`, reserve at least 8–10% margin (`right <= 0.92`, `left >= 0.06`). Never allow cards or annotations to reach the outer boundaries.
* **Saving Padding:** Always use `bbox_inches='tight', pad_inches=0.25` or `0.30` on `savefig`.
* **Headroom:** For horizontal and vertical bar charts, expand axis limits (`xlim >= max * 1.25` to `1.38`) so value labels have generous space.
* **Zero Collisions:** Legends and alert banners must never share overlapping coordinates. Use dedicated corners or bottom anchors with verified clearance.

---

### 4. Zero-Trust Verification Mandate
* Before claiming any visual asset is complete or pushing to `main`, agents must execute multimodal image inspection (`read_file` on the generated `.png`) to verify pixel-level alignment, label centering, and margin clearance.
