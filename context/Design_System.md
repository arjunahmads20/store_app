# Design System Documentation

This document serves as the single source of truth for the visual design of the Store App.

## 1. Color Palette

### 1.1 Brand Colors
| Name | Hex Code | Usage |
| :--- | :--- | :--- |
| **Brand Dark Purple** | `#31005C` | Primary Action Buttons, Active States, Highlights. (Primary) |
| **Brand Light Green** | `#73FFB7` | Accents, Secondary Actions, Banners. (Secondary) |
| **Brand Orange** | `#B14516` | Legacy / Alternate highlights. |
| **Brand Yellow** | `#FDF13B` | Legacy / Alternate accents. |

### 1.2 Semantic Colors
| Name | Value | Usage |
| :--- | :--- | :--- |
| **Primary** | `#31005C` | Main interactions. |
| **On Primary** | `#FFFFFF` | Text on primary buttons. |
| **Secondary** | `#73FFB7` | Secondary highlights. |
| **Surface** | `#FFFFFBFE` | Cards, Sheets, Dialogs (Slightly warm white). |
| **Background** | `#FAFAFA` | Main scaffold background (Off-white). |
| **Error** | `#B3261E` | Validation errors, Alerts. |
| **Text Primary** | `#1C1B1F` | Headlines, Body text. |
| **Text Secondary** | `#49454F` | Captions, Subtitles, Input Labels. |

---

## 2. Typography

**Font Family**: `GoogleFonts.inter`

| Style Name | Size | Weight | Line Height | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Display Large** | 57sp | Regular | 64sp | Hero Metrics. |
| **Headline Large** | 32sp | Regular | 40sp | Page Titles. |
| **Title Large** | 22sp | Regular | 28sp | Section Headers, Dialog Titles. |
| **Title Medium** | 16sp | Medium | 24sp | Card Titles. |
| **Body Large** | 16sp | Regular | 24sp | Main Content, inputs. |
| **Body Medium** | 14sp | Regular | 20sp | Secondary Content. |
| **Label Large** | 14sp | Medium | 20sp | Buttons. |

---

## 3. Spacing & Dimensions

### 3.1 Dimensions
*   **Standard Padding**: `16.0` (Page margins, Card internal padding).
*   **Standard Gap**: `12.0` (Between related items).
*   **Small Gap**: `8.0` (Icon to text).
*   **Section Gap**: `24.0` (Between major sections).

### 3.2 Component Sizes
*   **Button Height**: `50.0`.
*   **Input Height**: `50.0` (Standard), `40.0` (Search Bar / Compact).
*   **Icon Size**: `24.0` (Standard), `16.0` (Small/Inline).

### 3.3 Border Radius
*   **Standard**: `12.0` (Inputs, Buttons).
*   **Card**: `16.0` (Product Cards, Banners).
*   **Pill / Chip**: `20.0` or `30.0` (Search Bar, Filter Chips).

---

## 4. Component Styles

### 4.1 Input Fields
*   **Style**: Outlined or Filled (White on Grey Background).
*   **Border**: Grey `#E0E0E0` (Enabled), Dark Purple `#31005C` (Focused).
*   **Example**: Search Bar -> White fill, 1px grey border, radius 30px (Pill).

### 4.2 Buttons
*   **Primary**: Filled Dark Purple, White Text, Radius 12px.
*   **Secondary/Outlined**: Transparent, Dark Purple/Grey Border, Radius 12px.
*   **Ghost/Text**: No border, Dark Purple Text.

### 4.3 Cards
*   **Standard**: White background, Radius 16px, 1px Grey Border (`Colors.grey.shade200`), No Shadow (Flat).
*   **Elevated**: Use only for floating elements (Toasts, Dialogs).

### 4.4 Navigation
*   **height**: standard `NavigationBar` height.
*   **Icons**: Outlined/Solid based on selection.
*   **Selected Color**: Brand Dark Purple.

---

## 5. Layout Guidelines
*   **Grid**: 2 Columns for Products. Child Aspect Ratio ~0.60 - 0.75 depending on content.
*   **Safe Area**: Always respect `SafeArea` for top/bottom system bars.
*   **Scroll**: Use `Sliver` structure for complex scrolling pages (AppBar dissolves/scrolled-under).
