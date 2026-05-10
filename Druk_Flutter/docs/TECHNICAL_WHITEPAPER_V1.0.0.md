# Druk (微醺志) V1.1.0 Technical Whitepaper
## System Architecture, Biological Algorithms & Engineering Specification

---

## 1. System Architecture (系统架构)

Druk follows a Reactive Provider-based architecture (Flutter/Dart).

### Layers:
1.  **Logic Layer (The Brain)**: `AlcoholBrain` - A central `ChangeNotifier` that handles real-time calculations, persistence, and state broadcasting. It includes a **1-minute periodic timer** to drive real-time UI updates (BAC decay, countdowns).
2.  **UI Layer (The Tavern)**: Stateless/Stateful widgets that react to `AlcoholBrain` updates. Uses a custom `Glassmorphism` rendering engine.
3.  **Data Layer (The Ledger)**: Local storage using JSON serialization (SharedPreferences/Local File).

---

## 2. Biological Simulation & Rendering (生物模拟与渲染)

### 2.1 Core Formula: Modified Widmark (1932)
The basic BAC calculation is:
$$BAC = \frac{A \times 0.789}{W \times r \times 10} - (\beta \times T)$$
*   $A$: Alcohol consumed (ml) $\times$ ABV (%).
*   $W$: Body weight (kg).
*   $r$: Gender constant (Male: 0.68, Female: 0.55).
*   $\beta$: Metabolic rate (Slow: 0.012, Standard: 0.015, Fast: 0.018 %/h).
*   $T$: Time elapsed (hours).

### 2.2 Real-time Update Engine (实时引擎)
To ensure 1:1 parity with biological reality, the engine triggers a `recalculateBAC()` every **60 seconds**. This updates:
*   **Current BAC**: The decaying value based on metabolic rate.
*   **Distance to Safety**: A real-time countdown to the legal DUI limit (e.g., 0.02% or 0.08%).
*   **Sober Date**: The predicted timestamp of 0.000% BAC.

### 2.3 Smooth Curve Visualization (平滑渲染)
The sobriety curve in `BACChart` uses **Catmull-Rom Spline Interpolation** instead of linear or simple cubic segments. 
*   **Logic**: For every set of points $P_0, P_1, P_2, P_3$, the curve is drawn between $P_1$ and $P_2$.
*   **Precision**: 10 sub-segments are calculated between each data point to ensure a "cinematic" smooth trajectory.
*   **Dynamic Elements**: A red dashed vertical line ("NOW") moves horizontally across the X-axis (Time) based on the ratio of `elapsedTime` to `totalSessionDuration`.

---

## 3. Global Jurisdictions (全球法律标准)

Druk maintains a `CountryLaw` database to dynamically adjust safety thresholds:
*   **China/Europe**: 0.02% (DUI Warning) / 0.08% (Drunk Driving).
*   **US/UK**: 0.08% (Legal Limit).
*   **Japan**: 0.03%.
*   **UI Integration**: The `JurisdictionCard` highlights the limit in **Wine Red (#8B1A2B)** when the user's current BAC exceeds the selected country's threshold.

---

## 4. Persona System (人格系统)

The app features **8 distinct personas** (4 Male, 4 Female) that react to BAC levels:
*   **Selection Logic**: Personas are filtered based on the `Gender` profile setting.
*   **Interaction**: Headshots are rendered with a glassmorphic border. Selection triggers `HapticFeedback.heavyImpact()` and a scale animation ($1.0 \to 1.02$).
*   **Dynamic Quotes**: Each persona has a unique quote library that changes based on the 4 BAC states (Sober, Buzz, Gold, Over).

---

## 5. UI Design Specification (原子设计规范)

### Design Tokens
*   **SurfaceDim**: `#161310` (Background)
*   **Primary (Amber)**: `#D9A64D` (Data/Highlights)
*   **OnSurface**: `#F7EED9` (Warm Ivory Text)
*   **Warning (Red)**: `#8B1A2B` (Wine Red - Used for Limits/Alerts)

### Glassmorphism Spec
*   **Blur Radius**: 20px - 30px (BackdropFilter)
*   **Border**: 0.5px - 1.0px Solid with 0.1 opacity.

---

## 6. Implementation Note for AI Agents
When refactoring or porting this app:
1.  **Timer Priority**: Ensure the background timer is disposed correctly to prevent memory leaks.
2.  **Smoothing**: Do not fallback to standard line charts; the Catmull-Rom spline is essential for the "premium" aesthetic.
3.  **Local First**: All calculations must remain offline. No external API should be used for core BAC logic.

---
*Technical Specification V1.1.0 End.*
