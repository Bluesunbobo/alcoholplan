# Druk App Feature Update Log (iOS vs. Android)

This document tracks the feature parity and recent updates for both the iOS (Swift) and Android (Flutter) versions of the Druk (微醺志) application.

## Version Status
- **iOS**: V1.0.0 (Native Swift)
- **Android**: V1.0.0 (Flutter)

---

## Feature Parity & Recent Updates

### 1. Drink Recording (Confirm Pour)
| Feature | iOS Status | Android Status | Notes |
| :--- | :--- | :--- | :--- |
| **Real-time BAC Calc** | ✅ | ✅ | Bidirectional binding (BAC/ABV/Vol) |
| **Default Volumes** | ✅ | ✅ | Updated: Defaults to 0ml initially |
| **Inactivity Reset** | ❌ | ✅ | **New (Android)**: 1-min timeout resets volume |
| **BAC State Label** | ❌ | ✅ | **New (Android)**: Labels "实时" vs "预测" |
| **Quick Select Cards**| ✅ | ✅ | Beer, Wine, Whisky, etc. |

### 2. Poster Sharing (Poster Generation)
| Feature | iOS Status | Android Status | Notes |
| :--- | :--- | :--- | :--- |
| **3-Poster Logic** | ✅ | ✅ | Active sessions show 3 pages (Moment/Curve/Annual) |
| **2-Poster Logic** | ✅ | ✅ | Past sessions show 2 pages (Curve/Annual) |
| **Quote Rotation** | ✅ | ✅ | **New (Android)**: Randomized with 20-quote history |
| **Peak Time Accuracy**| ✅ | ✅ | Minute-level precision for history |

### 3. Localization & Privacy
| Feature | iOS Status | Android Status | Notes |
| :--- | :--- | :--- | :--- |
| **Bilingual UI** | ✅ | ✅ | Chinese/English support |
| **Privacy Policy** | ✅ | ✅ | Top nav visibility optimized |
| **Onboarding** | ✅ | ✅ | Cinematic intro included |

---

## Pending for Synchronization (Action Items)
- [ ] **Inactivity Reset**: Port the 1-minute timeout logic to iOS Swift version.
- [ ] **Quote Rotation History**: Verify if iOS uses a 20-quote buffer for randomization.
- [ ] **Default Volume (0ml)**: Ensure iOS starts with 0ml for pending drinks.

## Update History (Recent)
- **2026-05-15**: Optimized Android poster count (3 vs 2) and randomized annual quotes.
- **2026-05-15**: Implemented Android drink volume inactivity timeout (1 min) and 0ml default.
