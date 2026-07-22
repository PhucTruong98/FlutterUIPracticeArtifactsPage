# NovaShop — Flutter Mobile UI Specification
### AI Agent Design Reconstruction Guide

> This document provides complete design system instructions for rebuilding the NovaShop glassmorphism e-commerce app in Flutter for mobile. Every color, dimension, spacing value, component, screen layout, and interaction is specified here. Follow this document exactly.

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Design System — Tokens](#2-design-system--tokens)
3. [Typography](#3-typography)
4. [Iconography](#4-iconography)
5. [Components Library](#5-components-library)
6. [Screen: Home Page](#6-screen-home-page)
7. [Screen: Product Detail Page](#7-screen-product-detail-page)
8. [Screen: Cart Drawer / Bottom Sheet](#8-screen-cart-drawer--bottom-sheet)
9. [Navigation Architecture](#9-navigation-architecture)
10. [Animations & Interactions](#10-animations--interactions)
11. [Flutter Implementation Notes](#11-flutter-implementation-notes)

---

## 1. Design Philosophy

**Aesthetic:** Glassmorphism on deep-navy dark background. Premium, modern, high-contrast.

**Core principles:**
- Every card is a frosted-glass panel: semi-transparent background, backdrop blur, thin luminous border
- The background is never plain — it has floating radial gradient "orbs" that give depth
- Typography is a two-family system: `Outfit` (display/headings, high weight) + `Plus Jakarta Sans` (body/UI)
- Accent hierarchy: Indigo (`#6366F1`) for interactive/primary, Amber (`#F59E0B`) for CTAs and pricing, Emerald (`#10B981`) for positive states, Red (`#EF4444`) for danger/discount badges
- Every interactive element has a visible hover/press state using opacity shift or scale
- Spacing is generous — never feel cramped

---

## 2. Design System — Tokens

### 2.1 Color Palette

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────
  static const Color background       = Color(0xFF050D1F); // page background
  static const Color backgroundAlt    = Color(0xFF060C1A); // subtle variation
  static const Color card             = Color(0xFF0D1635); // card base (before opacity)
  static const Color surface          = Color(0xFF111C38); // elevated surfaces

  // ── Glass surfaces (use with BackdropFilter) ──────────────────
  // Apply these as container colors + ClipRRect + BackdropFilter
  static const Color glassCard        = Color(0x1A0D1635); // cards: rgba(13,22,53, 0.60)
  static const Color glassNavbar      = Color(0xD9050D1F); // navbar: rgba(5,13,31, 0.85)
  static const Color glassDrawer      = Color(0xF7050D1F); // drawer: rgba(5,13,31, 0.97)
  static const Color glassBuyBox      = Color(0xCC0D1635); // buy box: rgba(13,22,53, 0.80)

  // ── Borders (glass hairlines) ─────────────────────────────────
  static const Color border           = Color(0x140A0E1A); // rgba(255,255,255, 0.08)
  static const Color borderLight      = Color(0x33FFFFFF); // rgba(255,255,255, 0.20) on hover
  static const Color borderFocus      = Color(0x996366F1); // indigo focus ring

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary      = Color(0xFFE2E8F5); // main text
  static const Color textSecondary    = Color(0xFFB8C4DD); // secondary text
  static const Color textMuted        = Color(0xFF7A8AAA); // captions/labels
  static const Color textDisabled     = Color(0xFF3D4F6B); // disabled

  // ── White opacity helpers ─────────────────────────────────────
  static Color white5  = Colors.white.withOpacity(0.05);
  static Color white8  = Colors.white.withOpacity(0.08);
  static Color white10 = Colors.white.withOpacity(0.10);
  static Color white15 = Colors.white.withOpacity(0.15);
  static Color white20 = Colors.white.withOpacity(0.20);
  static Color white40 = Colors.white.withOpacity(0.40);
  static Color white50 = Colors.white.withOpacity(0.50);
  static Color white60 = Colors.white.withOpacity(0.60);
  static Color white70 = Colors.white.withOpacity(0.70);

  // ── Primary — Indigo ─────────────────────────────────────────
  static const Color primary          = Color(0xFF6366F1);
  static const Color primaryLight     = Color(0xFF818CF8); // hover state
  static const Color primaryDark      = Color(0xFF4F46E5); // pressed state
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color primarySubtle    = Color(0x336366F1); // rgba(99,102,241, 0.20)
  static const Color primaryBorder    = Color(0x806366F1); // rgba(99,102,241, 0.50)
  static const Color primaryShadow    = Color(0x406366F1); // rgba(99,102,241, 0.25)

  // ── Accent — Amber / Gold ────────────────────────────────────
  static const Color accent           = Color(0xFFF59E0B);
  static const Color accentLight      = Color(0xFFFBBF24);
  static const Color accentForeground = Color(0xFF0A0E1A); // black on amber
  static const Color accentSubtle     = Color(0x1AF59E0B); // rgba(245,158,11, 0.10)
  static const Color accentBorder     = Color(0x4DF59E0B); // rgba(245,158,11, 0.30)
  static const Color accentShadow     = Color(0x33F59E0B); // rgba(245,158,11, 0.20)

  // ── Semantic colors ───────────────────────────────────────────
  static const Color success          = Color(0xFF10B981); // emerald
  static const Color successSubtle    = Color(0x1A10B981);
  static const Color successBorder    = Color(0x3310B981);

  static const Color danger           = Color(0xFFEF4444); // red
  static const Color dangerSubtle     = Color(0x1AEF4444);
  static const Color dangerBorder     = Color(0x33EF4444);

  static const Color info             = Color(0xFF0EA5E9); // sky blue
  static const Color infoSubtle       = Color(0x1A0EA5E9);
  static const Color infoBorder       = Color(0x330EA5E9);

  static const Color violet           = Color(0xFF8B5CF6);
  static const Color violetSubtle     = Color(0x1A8B5CF6);
  static const Color violetBorder     = Color(0x338B5CF6);

  // ── Rating / Star ─────────────────────────────────────────────
  static const Color starFilled       = Color(0xFFFBBF24); // amber-400
  static const Color starEmpty        = Color(0x1AFFFFFF); // white/10

  // ── Gradient orbs (background decorative) ────────────────────
  static const Color orbIndigo        = Color(0x266366F1); // rgba(99,102,241, 0.15)
  static const Color orbViolet        = Color(0x1F8B5CF6); // rgba(139,92,246, 0.12)
  static const Color orbCyan          = Color(0x1A0EA5E9); // rgba(14,165,233, 0.10)
}
```

### 2.2 Spacing Scale

```dart
// lib/core/theme/app_spacing.dart
// Based on 4pt base grid

class AppSpacing {
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double base = 16.0;
  static const double lg   = 20.0;
  static const double xl   = 24.0;
  static const double xl2  = 32.0;
  static const double xl3  = 40.0;
  static const double xl4  = 48.0;
  static const double xl5  = 64.0;
}
```

### 2.3 Border Radius Scale

```dart
class AppRadius {
  static const double xs   = 6.0;
  static const double sm   = 8.0;
  static const double md   = 10.0;
  static const double base = 12.0;
  static const double lg   = 14.0;
  static const double xl   = 16.0;
  static const double xl2  = 20.0;
  static const double xl3  = 24.0;
  static const double full = 999.0; // pill/circle
}
```

### 2.4 Shadows & Elevation

```dart
class AppShadows {
  // Card glass shadow
  static List<BoxShadow> card = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 24, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 1)),
  ];

  // Primary button glow
  static List<BoxShadow> primaryGlow = [
    BoxShadow(color: Color(0x406366F1), blurRadius: 24, offset: Offset(0, 8)),
  ];

  // Accent/CTA button glow
  static List<BoxShadow> accentGlow = [
    BoxShadow(color: Color(0x33F59E0B), blurRadius: 20, offset: Offset(0, 6)),
  ];

  // Navbar bottom shadow
  static List<BoxShadow> navbar = [
    BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 4)),
  ];
}
```

### 2.5 Background Gradient

```dart
// The page background — apply to root Scaffold body
static const LinearGradient pageBackground = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.4, 1.0],
  colors: [
    Color(0xFF050D1F),
    Color(0xFF080E20),
    Color(0xFF060C1A),
  ],
);
```

### 2.6 Glassmorphism Helper

Every glass card uses this pattern in Flutter:

```dart
// lib/core/widgets/glass_container.dart

Widget glassContainer({
  required Widget child,
  Color bgColor = const Color(0x990D1635),  // adjust per context
  double blur = 16.0,
  double borderRadius = AppRadius.xl2,
  Color borderColor = const Color(0x14FFFFFF),
  double borderWidth = 1.0,
  List<BoxShadow>? shadows,
  EdgeInsets? padding,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: shadows ?? AppShadows.card,
        ),
        padding: padding,
        child: child,
      ),
    ),
  );
}
```

> **Important:** `BackdropFilter` with `ImageFilter.blur` only shows blur effect if the widget is rendered over content. Make sure the scaffold background has the gradient + orbs rendered behind all content.

---

## 3. Typography

### 3.1 Font Families

```yaml
# pubspec.yaml — add Google Fonts package
dependencies:
  google_fonts: ^6.1.0
```

```dart
// lib/core/theme/app_text_styles.dart
import 'package:google_fonts/google_fonts.dart';

// Primary display/heading font
// Font: Outfit — weights 400, 500, 600, 700, 800, 900
TextStyle outfitStyle({
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.w400,
  Color color = AppColors.textPrimary,
  double? letterSpacing,
  double? height,
}) => GoogleFonts.outfit(
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
  letterSpacing: letterSpacing,
  height: height,
);

// Body/UI font
// Font: Plus Jakarta Sans — weights 400, 500, 600, 700, 800
TextStyle jakartaStyle({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = AppColors.textPrimary,
  double? letterSpacing,
  double? height,
}) => GoogleFonts.plusJakartaSans(
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
  letterSpacing: letterSpacing,
  height: height,
);
```

### 3.2 Type Scale

| Token | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| `displayXL` | Outfit | 32sp | 900 | Hero title |
| `displayLG` | Outfit | 26sp | 800 | Section hero |
| `displayMD` | Outfit | 22sp | 700 | Page titles |
| `displaySM` | Outfit | 18sp | 700 | Card titles, section headers |
| `headingMD` | Outfit | 16sp | 600 | Product name in detail |
| `headingSM` | Outfit | 14sp | 600 | Sub-headings |
| `bodyLG` | Plus Jakarta Sans | 15sp | 400 | Product descriptions |
| `bodyMD` | Plus Jakarta Sans | 14sp | 400 | Standard body text |
| `bodySM` | Plus Jakarta Sans | 13sp | 400 | Secondary body text |
| `labelLG` | Plus Jakarta Sans | 13sp | 600 | Buttons, important labels |
| `labelMD` | Plus Jakarta Sans | 12sp | 600 | Tags, badges, nav items |
| `labelSM` | Plus Jakarta Sans | 11sp | 500 | Captions, metadata |
| `labelXS` | Plus Jakarta Sans | 10sp | 700 | Micro badges, uppercase labels |
| `priceXL` | Outfit | 28sp | 900 | Main price in buy box |
| `priceLG` | Outfit | 20sp | 700 | Product card price |
| `priceMD` | Outfit | 16sp | 700 | Compact price display |

```dart
class AppTextStyles {
  static TextStyle displayXL = outfitStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -1.0);
  static TextStyle displayLG = outfitStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.5);
  static TextStyle displayMD = outfitStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2);
  static TextStyle displaySM = outfitStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3);
  static TextStyle headingMD = outfitStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle headingSM = outfitStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle bodyLG    = jakartaStyle(fontSize: 15, height: 1.6);
  static TextStyle bodyMD    = jakartaStyle(fontSize: 14, height: 1.6);
  static TextStyle bodySM    = jakartaStyle(fontSize: 13, height: 1.5);
  static TextStyle labelLG   = jakartaStyle(fontSize: 13, fontWeight: FontWeight.w600);
  static TextStyle labelMD   = jakartaStyle(fontSize: 12, fontWeight: FontWeight.w600);
  static TextStyle labelSM   = jakartaStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted);
  static TextStyle labelXS   = jakartaStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8);
  static TextStyle priceXL   = outfitStyle(fontSize: 28, fontWeight: FontWeight.w900);
  static TextStyle priceLG   = outfitStyle(fontSize: 20, fontWeight: FontWeight.w700);
  static TextStyle priceMD   = outfitStyle(fontSize: 16, fontWeight: FontWeight.w700);
}
```

---

## 4. Iconography

Use the `lucide_icons` Flutter package (or `flutter_lucide`). All icons in the app come from this set.

```yaml
dependencies:
  lucide_icons: ^0.0.4
```

| Icon | Usage | Size | Color |
|------|-------|------|-------|
| `LucideIcons.zap` | Logo icon, Prime badge | 16–18 | white / blue-400 |
| `LucideIcons.search` | Search bar | 16 | white |
| `LucideIcons.shoppingCart` | Cart button | 20 | white/70 |
| `LucideIcons.user` | Account button | 18 | white/70 |
| `LucideIcons.bell` | Notifications | 18 | white/70 |
| `LucideIcons.mapPin` | Delivery location | 14 | white/60 |
| `LucideIcons.chevronDown` | Dropdowns | 12 | white |
| `LucideIcons.chevronRight` | Section CTAs, breadcrumb | 14 | indigo-400 |
| `LucideIcons.arrowLeft` | Back navigation | 16 | indigo-400 |
| `LucideIcons.heart` | Wishlist / favourite | 14–18 | white/50 → red when active |
| `LucideIcons.star` | Star rating | 12–18 | amber-400 filled, white/10 empty |
| `LucideIcons.plus` | Add to cart, quantity | 12–14 | white |
| `LucideIcons.minus` | Reduce quantity | 12–14 | white |
| `LucideIcons.menu` | Hamburger / "All" | 12–14 | white |
| `LucideIcons.x` | Close drawer/modal | 16 | white/70 |
| `LucideIcons.truck` | Delivery info | 12–14 | blue-400 |
| `LucideIcons.shield` | Security | 12 | white/35 |
| `LucideIcons.package` | Returns | 12–18 | indigo-400 |
| `LucideIcons.check` | Verified, highlights | 9–12 | indigo-400 / emerald-400 |
| `LucideIcons.filter` | Filter | 14 | white/60 |
| `LucideIcons.tag` | Deals | 12 | white/60 |

---

## 5. Components Library

### 5.1 Star Rating

**Visual:** Row of 5 stars. Filled stars = `starFilled` color with fill. Empty = `starEmpty`.

```
[★][★][★][★][☆]   4.0 rating = 4 filled, 1 empty
```

**Specs:**
- Default icon size: `12sp` in product cards, `16sp` in detail page, `18sp` in rating summary
- Gap between stars: `2dp`
- When `showNumber = true`: number appears right of stars, color `accentLight (#FBBF24)`, font `labelLG`
- Review count appears right of stars as `"(12,847)"` in `labelSM` `textMuted` color

---

### 5.2 Badge Chip

Small pill label overlaid on product images and next to product titles.

**Variants and colors:**

| Label | BG Color | Text Color | Border Color |
|-------|----------|------------|--------------|
| Best Seller | `accentSubtle` (#F59E0B/20%) | `#FCD34D` (amber-300) | `accentBorder` |
| Deal | `dangerSubtle` (#EF4444/20%) | `#FCA5A5` (red-300) | `dangerBorder` |
| New | `successSubtle` (#10B981/20%) | `#6EE7B7` (emerald-300) | `successBorder` |
| Limited | `violetSubtle` (#8B5CF6/20%) | `#C4B5FD` (violet-300) | `violetBorder` |

**Specs:**
- Padding: `horizontal 8dp, vertical 3dp`
- Border radius: `AppRadius.full` (pill)
- Border width: `1dp`
- Font: `labelXS` (10sp, weight 700, uppercase, letter-spacing 0.8)

---

### 5.3 App Logo

```
[Zap icon in indigo rounded square] nova[shop in indigo]
```

**Logo icon container:**
- Size: `32×32dp`
- Border radius: `8dp`
- Background: `primary (#6366F1)`
- Shadow: `BoxShadow(color: 0x4D6366F1, blurRadius: 12, offset: Offset(0,4))`
- Icon: `LucideIcons.zap` size `16`, color white, filled

**Wordmark:**
- "nova" — Outfit 800, 20sp, white
- "shop" — Outfit 800, 20sp, primaryLight `#818CF8`
- No space between words

---

### 5.4 Search Bar

Full-width input with attached search button.

```
┌─────────────────────────────────────────┐
│  🔍  Search products, brands...  [  🔍  ]│
└─────────────────────────────────────────┘
```

**Container:**
- Background: `white5` (5% white)
- Border: `1dp border` color `border (white/8%)`
- Border radius: `AppRadius.xl (16dp)` — pill-like
- Height: `44dp`
- Backdrop blur: `8dp`

**Text field:**
- Font: `bodyMD`, color `textPrimary`, placeholder color `textMuted`
- Horizontal padding: `16dp`
- Background: transparent

**Search button (right side):**
- Width: `48dp`, full height
- Background: `primary (#6366F1)`
- Border radius: right side only — `BorderRadius.only(topRight: 16, bottomRight: 16)`
- Icon: `LucideIcons.search` size 16, white
- On press: scale to 0.95, color slightly lighter

**Focus state:**
- Border color changes to `borderFocus (#9966366F1)` — indigo at 60% opacity
- Background: `white8`

---

### 5.5 Primary Button

```
┌──────────────────────────────────┐
│         Add to Cart 🛒           │
└──────────────────────────────────┘
```

**Specs:**
- Height: `48dp`
- Border radius: `AppRadius.xl (16dp)`
- Background: `primary (#6366F1)`
- Text: `labelLG`, white, weight 700
- Shadow: `primaryGlow`
- On press: scale `0.97`, slightly darker bg `primaryDark`

---

### 5.6 CTA / Buy Now Button (Amber)

```
┌──────────────────────────────────┐
│            Buy Now               │
└──────────────────────────────────┘
```

**Specs:**
- Height: `48dp`
- Border radius: `AppRadius.xl (16dp)`
- Background: `accent (#F59E0B)`
- Text: `labelLG`, `accentForeground (#0A0E1A)`, weight 700
- Shadow: `accentGlow`
- On press: scale `0.97`, slightly lighter `accentLight`

---

### 5.7 Ghost / Secondary Button

- Height: `44dp`
- Border radius: `AppRadius.xl`
- Background: `white8`
- Border: `1dp`, `border (white/8%)`
- Text: `labelLG`, `textPrimary`, weight 600
- On press: background → `white15`

---

### 5.8 Icon Button (Circular)

Used for wishlist, quantity controls, close button.

**Small (32×32dp):**
- Border radius: `AppRadius.xl (16dp)` — square-ish rounded
- Background: `white8`
- Border: `1dp border`
- Icon size: `12–14dp`

**Large (40×40dp):**
- Same style but bigger, used on product images (wishlist overlay)
- Background: `rgba(0,0,0, 0.40)` + backdrop blur `8dp`

---

### 5.9 Quantity Stepper

```
  [−]   2   [+]
```

**Container:** `Row` with `gap 12dp`
- Minus/Plus buttons: `36×36dp`, `white8` bg, `border`, radius `AppRadius.base`
- Count: `Outfit 700 18sp white`, width `24dp`, centered
- On decrement to 1 → minus button dims to `white5`
- On increment → no limit until some max

---

### 5.10 Prime Badge

```
⚡ prime
```

- Container: `infoSubtle` bg, `infoBorder` border, `radius AppRadius.xs (6dp)`
- Padding: `horizontal 6dp, vertical 3dp`
- Icon: `LucideIcons.zap` filled, size 9, color `info (#0EA5E9)`
- Text: `labelXS` (10sp, 700), color `info`, uppercase

---

### 5.11 Product Card

Mobile card size: full width in vertical list, or half-width (minus 20dp total gap) in 2-column grid.

```
┌────────────────────────────────┐  ← ClipRRect radius 20dp
│                        [♡]     │  ← wishlist btn top-right
│  [Best Seller]                 │  ← badge top-left (when present)
│                                │
│     [Product Image]            │  ← height 160dp, object-fit cover
│                   [-X%]        │  ← discount badge bottom-left of image
├────────────────────────────────┤
│ Electronics · Headphones       │  ← subcategory labelXS textMuted uppercase
│ Sony WH-1000XM5 Wireless       │  ← headingSM white, max 2 lines, ellipsis
│ Noise-Canceling Headphones     │
│ ★★★★★  4.8  (12,847)          │  ← stars + rating + count
│ ⚡ prime  · Free delivery      │  ← prime badge + delivery text
│                                │
│  $279.99  ~~$399.99~~   [+]   │  ← price row + add button
└────────────────────────────────┘
```

**Card container:**
- Background: `glassCard` (rgba(13,22,53, 0.60))
- Backdrop blur: `16dp`
- Border: `1dp`, `border (white/8%)`
- Border radius: `AppRadius.xl3 (24dp)`
- Shadow: `AppShadows.card`
- On hover/press: border → `borderLight (white/20%)`, translateY `-4dp` (animated)

**Image section:**
- Height: `160dp`
- Clipped to card border radius (top corners only)
- Background color (while loading): `white5` gradient
- Image fit: `BoxFit.cover`
- On hover: scale `1.05`, duration `500ms`, curve `Curves.easeOut`

**Discount badge (over image, bottom-left):**
- Absolute positioned `bottom: 8dp, left: 8dp`
- Background: `danger (#EF4444)`
- Text: `labelXS` white
- Padding: `4dp horizontal, 2dp vertical`
- Border radius: `4dp`
- Content: `-30%` (calculate from price/originalPrice)

**Wishlist button (over image, top-right):**
- Absolute positioned `top: 8dp, right: 8dp`
- Size: `32×32dp`
- Background: `rgba(0,0,0,0.40)` + blur `8dp`
- Border: `1dp border`
- Border radius: `AppRadius.full`
- Icon: `LucideIcons.heart` size 13, color `white50` default → `danger` when liked (filled)

**Content padding:** `14dp` all sides

**Subcategory line:**
- Font: `labelXS` (10sp, 700, uppercase, tracking 0.8)
- Color: `textMuted`
- Margin bottom: `4dp`

**Product name:**
- Font: `headingSM` (14sp, 600)
- Color: `textPrimary` → `primaryLight` on card hover
- Max 2 lines with ellipsis
- Margin bottom: `6dp`

**Star rating row:**
- Stars size: `12dp`
- Rating number: `labelSM` `accentLight`
- Review count: `labelSM` `textMuted`
- Margin bottom: `6dp`

**Prime + delivery row:**
- Prime badge (see 5.10)
- Dot separator: `white30`
- "Free delivery" text: `labelSM` `textMuted`
- Margin bottom: `8dp`

**Price row:**
- Current price: `priceLG` (Outfit 20sp 700) white
- Original price (strikethrough): `bodySM` `textDisabled`, `TextDecoration.lineThrough`
- Spacer fills between price and add button
- Add button: `32×32dp` glass icon button with `plus` icon, background `primarySubtle` with `1dp primaryBorder`, icon color `primary`

---

### 5.12 Deal Card (Horizontal Scroll)

Compact card for "Today's Deals" row.

```
┌───────────┐
│  [-30%]   │  ← red badge overlaid
│  [Image]  │  ← height 128dp
│───────────│
│ Sony WH.. │  ← 2 lines bodySM white
│ $279.99   │  ← priceMD accent
└───────────┘
```

- Width: `148dp`
- Image height: `128dp`
- Border radius: `AppRadius.xl2 (20dp)`
- Same glass treatment as ProductCard
- Padding below image: `10dp`
- On press: border becomes `accentBorder (amber/30%)`

---

### 5.13 Category Icon Tile

Used in "Shop by Category" 4-column grid.

```
┌─────────────┐
│      💻     │  ← emoji size 26sp
│  Electronics│  ← labelSM centered, 2 lines ok
└─────────────┘
```

- Aspect ratio: `1:1`
- Border radius: `AppRadius.xl2 (20dp)`
- Background: gradient from category color (see list below) blended over `white5`
- Border: `1dp border`
- On press: scale `1.05`, border → `borderLight`

**Category gradients (from → to, 135° angle):**

| Category | From | To |
|----------|------|----|
| Electronics | `rgba(37,99,235, 0.20)` | `rgba(99,102,241, 0.10)` |
| Fashion | `rgba(219,39,119, 0.20)` | `rgba(225,29,72, 0.10)` |
| Home | `rgba(217,119,6, 0.20)` | `rgba(234,88,12, 0.10)` |
| Outdoors | `rgba(5,150,105, 0.20)` | `rgba(13,148,136, 0.10)` |
| Watches | `rgba(71,85,105, 0.20)` | `rgba(75,85,99, 0.10)` |
| Cameras | `rgba(109,40,217, 0.20)` | `rgba(124,58,237, 0.10)` |
| Books | `rgba(8,145,178, 0.20)` | `rgba(14,165,233, 0.10)` |
| Beauty | `rgba(192,38,211, 0.20)` | `rgba(219,39,119, 0.10)` |

---

### 5.14 Feature Strip Tile

Used in the 2×2 grid at bottom of home page.

```
┌─────────────────────────────────────┐
│  [Icon box]  Free Shipping          │
│              On orders over $35     │
└─────────────────────────────────────┘
```

- Height: `64dp`
- Border radius: `AppRadius.xl2`
- Glass: `glassCard` bg + `8dp blur` + `border`
- Icon box: `40×40dp`, `primarySubtle` bg, `primaryBorder` border, `AppRadius.xl`, icon `18sp primary`
- Title: `labelLG` (13sp 600) white
- Subtitle: `labelSM` `textMuted`
- Gap between icon box and text: `12dp`
- Horizontal padding: `14dp`

---

### 5.15 Review Card

```
┌─────────────────────────────────────┐
│ [AV]  Marcus T.    ✓ Verified       │
│       ★★★★★   Dec 15, 2024         │
│                                     │
│ Best headphones I've ever owned     │
│ The noise cancellation is...        │
└─────────────────────────────────────┘
```

- Full width
- Glass: `glassCard` + `12dp blur` + `border`
- Border radius: `AppRadius.xl2`
- Padding: `16dp`

**Avatar:**
- Size: `40×40dp`
- Border radius: `AppRadius.full`
- Background: gradient from `indigo-600/60` to `violet-600/40`
- Border: `1dp primaryBorder`
- Text: initials in `indigo-200`, `labelLG` (13sp 600)

**Author name:** `labelLG` white
**Stars + date:** inline row, stars size 11, date `labelSM textMuted`
**Verified badge:** pushed to right, emerald-400, `Check` icon 9sp + "Verified Purchase" `labelXS`

**Review title:** `labelLG` (13sp 600) white, margin top `10dp`
**Review body:** `bodySM` (13sp) `textSecondary` (B8C4DD), line height 1.5

---

### 5.16 Rating Summary Bar

In product detail, above the reviews list.

```
Rating: 4.8 ★★★★★  12,847 reviews
─────────────────────────────────────
5 ★  [████████████████░░░]  68%
4 ★  [████░░░░░░░░░░░░░░░]  22%
3 ★  [█░░░░░░░░░░░░░░░░░░]   7%
2 ★  [░░░░░░░░░░░░░░░░░░░]   2%
1 ★  [░░░░░░░░░░░░░░░░░░░]   1%
```

**Big rating number:** `displayXL` (32sp 900) white
**Stars:** size 18, with `showNumber = false`
**Review count:** `bodySM textMuted`

**Bar rows:**
- Star label: `labelSM textMuted` width `28dp`
- Bar: `8dp height`, `white8` background, `accentLight (#FBBF24)` fill, `borderRadius 4dp`
- Percent label: `labelSM textMuted` width `28dp` right-aligned

---

### 5.17 Tab Bar (Overview / Specs / Reviews)

Three-segment selector within the product detail page.

```
┌─────────────────────────────────┐
│  Overview  │  Specs  │  Reviews │
└─────────────────────────────────┘
```

- Container: `white5` bg, `border`, `4dp padding`, `AppRadius.xl`
- Each tab: `labelMD` (12sp 600) capitalize
- Active tab: `primary bg` + white text + `primaryShadow` shadow + `AppRadius.base`
- Inactive tab: `textMuted` → `textPrimary` on hover

---

### 5.18 Navbar — Top App Bar

Fixed at top, uses `SliverAppBar` or custom `Stack`-positioned widget.

```
┌──────────────────────────────────────────────────────┐  ← 56dp height
│ [Logo]   📍 New York  ▼        [🔔] [👤] [🛒 (2)] │
└──────────────────────────────────────────────────────┘
```

**Background:** `glassNavbar (rgba(5,13,31, 0.85))` + `backdrop blur 24dp`
**Bottom border:** `1dp border (white/8%)`
**Height:** `56dp` + safe area insets top
**Left padding:** `16dp`, **right padding:** `12dp`
**Item gaps:** `4dp` between right icons

**Logo:** see 5.3
**Location button:**
- "Deliver to" label: `labelXS textMuted`
- City + chevron: `labelMD white 600`
- Total width: compact, max `96dp`

**Right icon buttons:**
- Bell: `40×40dp tap target`, icon `18sp white70`
- Account: icon + "Account" text visible if space allows
- Cart:
  - `ShoppingCart` icon `20sp white70`
  - Badge counter: `16×16dp circle`, `accent (#F59E0B)` bg, black text `labelXS`, positioned `top-right of icon`
  - When count > 9: show "9+"

---

### 5.19 Category Navigation Bar

Below the main navbar, horizontal scroll row.

**Height:** `40dp`
**Background:** same as navbar bottom edge (no additional bg, blends in)
**Top border:** `1dp border (white/5%)` — very subtle separator

**"All" button (first item):**
- Background: `white8`
- Border radius: `AppRadius.base`
- Has `Menu` icon before text
- Height: `28dp`, `horizontal 12dp padding`
- Font: `labelMD (12sp 600)` white

**Category buttons:**
- No background (transparent)
- On active: `white8` background
- Font: `labelMD` `textMuted` → white on hover/active
- Height: `28dp`

**"Today's Deals" button:**
- Text color: `Color(0xFFfbbf24)` amber (at 80% opacity)
- Has `Zap` icon before text
- On hover: amber-300 text

**Scroll behavior:** horizontal, no scrollbar visible

---

### 5.20 Hero Banner

Full-width banner with image background, gradient overlay, and CTA.

```
┌──────────────────────────────────────┐  ← height 260dp on mobile
│                                      │
│  Featured Deal  [Best Seller]        │
│                                      │
│  Next-Gen Audio                      │  ← displayLG (26sp 800)
│  Experience silence like             │  ← bodyLG textSecondary
│  never before                        │
│                                      │
│  $279.99  ~~$399.99~~  Save 30%     │
│                                      │
│  [Shop Headphones] [View Details]    │
│                                      │
│                    ● ○ ○             │  ← slide indicators bottom-right
└──────────────────────────────────────┘
```

**Container:**
- Height: `260dp` on mobile (scales up on tablets)
- Border radius: `AppRadius.xl3 (24dp)`
- `ClipRRect` to clip the image

**Background image:**
- `Image.network` with `BoxFit.cover`
- Slightly scaled `1.05x` with subtle parallax or just static

**Gradient overlay (left-to-right):**
- `LinearGradient`, angle `0° (left → right)`
- Colors: `[slide.gradient.from, slide.gradient.mid, Colors.transparent]`
- Stops: `[0.0, 0.5, 1.0]`

**Second overlay (top-to-bottom from bottom):**
- `LinearGradient`, angle `270°`
- `Colors.black60 → transparent`
- This ensures text is readable regardless of image

**Content padding:** `20dp` left, `16dp` top/bottom, `right 50%` (text takes left half)

**"Featured Deal" pre-badge:**
- Font: `labelXS` uppercase tracking 1.5
- Color: `white50`
- Border: `1dp white/20%`
- Border radius: `AppRadius.full`
- Padding: `4dp vertical, 12dp horizontal`
- Margin bottom: `8dp`

**Headline:**
- `displayLG` (26sp 800) white
- Letter spacing: `-0.5`
- Margin bottom: `4dp`

**Subheadline:**
- `bodyLG` `white70`
- Margin bottom: `8dp`

**Price row:**
- Current price: `priceLG` (20sp 700) white
- Original: strikethrough `bodySM white40`
- Save badge: `"Save X%"` in `success (#10B981)` `labelSM 600`
- Margin bottom: `16dp`

**CTA buttons row:**
- Primary button (slide accent color): height `40dp`, `12dp horizontal padding`
- Ghost button: height `40dp`, `white/10` bg, border `white/20%`
- Gap: `10dp`

**Slide indicators (bottom):**
- Position: `bottom 16dp, right 16dp`
- Active: `8×6dp` white rounded pill
- Inactive: `6×6dp` `white30` circle
- Gap: `6dp`
- Tappable to switch slide

**Auto-advance:** every `4 seconds`, smooth `PageView` or manual state animation

---

## 6. Screen: Home Page

### 6.1 Layout Structure

The home page is a `CustomScrollView` with `SliverList` / `SliverPadding` for sections.

```
SafeArea
└── Stack
    ├── BackgroundWidget (gradient + orbs, fixed behind everything)
    └── CustomScrollView
        ├── SliverAppBar (sticky Navbar + category bar)
        └── SliverPadding(padding: EdgeInsets.all(16))
            └── SliverList
                ├── HeroBanner (260dp)
                ├── SizedBox(16)
                ├── TodaysDealsSection
                ├── SizedBox(24)
                ├── ShopByCategorySection
                ├── SizedBox(24)
                ├── BestSellersSection
                ├── SizedBox(24)
                ├── ElectronicsSection
                ├── SizedBox(24)
                ├── AllProductsSection
                ├── SizedBox(24)
                ├── FeatureStrip
                └── SizedBox(32)
```

### 6.2 Background Widget

This renders the page background gradient + floating orbs. It is `Positioned.fill` behind all scrollable content.

```dart
Container(
  decoration: BoxDecoration(gradient: AppColors.pageBackground),
  child: Stack(children: [
    // Orb 1 — top-center-left, indigo
    Positioned(
      top: -100, left: MediaQuery.of(context).size.width * 0.1,
      child: Container(
        width: 400, height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            AppColors.orbIndigo,   // center: rgba(99,102,241,0.15)
            Colors.transparent,    // edge: transparent
          ]),
        ),
      ),
    ),
    // Orb 2 — middle-right, violet
    Positioned(
      top: 500, right: -50,
      child: Container(width: 320, height: 320, /* violet orb */ ),
    ),
    // Orb 3 — lower-left, cyan
    Positioned(
      bottom: 200, left: -80,
      child: Container(width: 360, height: 360, /* cyan orb */ ),
    ),
  ]),
)
```

### 6.3 Section Headers

Each section has a consistent header with left accent bar:

```
│ [1dp colored bar] Section Title        See all >
```

**Pattern:**
- `Row` with `crossAxisAlignment.center`
- Left accent bar: `Container(width: 4, height: 24, borderRadius: 2, color: sectionAccentColor)`
- Gap: `12dp`
- Title: `displaySM` (18sp 700) white
- Optional subtitle/timer on same row
- Spacer
- "View all" link: `labelMD` `primary` + `ChevronRight` icon 14sp

**Section accent colors:**
- Today's Deals: `accent (#F59E0B)`
- Shop by Category: `primary (#6366F1)`
- Best Sellers: `violet (#8B5CF6)`
- Electronics: `info (#0EA5E9)`
- All Products: `success (#10B981)`

### 6.4 Today's Deals Section

```
[Section header with countdown timer]
─────────────────────────────────────
[DealCard] [DealCard] [DealCard] [DealCard]  ← horizontal ListView
```

**Countdown timer:**
- Format: `HH:MM:SS`
- Displayed in `label MD` weight 700 `accentLight` color
- Container: `accentSubtle` bg, `accentBorder` border, `AppRadius.base`, `6dp vertical 10dp horizontal padding`
- Font: `monospace / Outfit`
- Implemented with `Timer.periodic(Duration(seconds: 1), ...)`
- Initial value: `08:47:23` (or real countdown)

**Horizontal list:**
- `ListView.builder` with `scrollDirection: Axis.horizontal`
- `itemExtent: 148dp`
- Gap: `12dp`
- `ClipRect` with padding `bottom: 8dp` so card shadows show

### 6.5 Shop by Category Section

4-column grid (2 rows) of `CategoryIconTile`:

```
[Electronics] [Fashion]  [Home]    [Outdoors]
[Watches]     [Cameras]  [Books]   [Beauty]
```

**Grid:**
- `GridView.count(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10)`
- `childAspectRatio: 1.0`

### 6.6 Best Sellers + Electronics + All Products Sections

**Grid:** `GridView.count(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12)`

Each section uses the same `ProductCard` component. Cards have `2:2.8` aspect ratio approximately (the card height is variable based on content but approximately `280dp`).

Use `shrinkWrap: true` with `NeverScrollableScrollPhysics()` inside the outer `CustomScrollView`.

### 6.7 Feature Strip

2×2 grid of `FeatureStripTile`:

```
[Free Shipping]   [Secure Payment]
[Easy Returns]    [Fast Delivery]
```

- `GridView.count(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.8)`

---

## 7. Screen: Product Detail Page

### 7.1 Layout Structure

```
Scaffold (no AppBar — custom back nav)
└── Stack
    ├── BackgroundWidget
    └── CustomScrollView
        ├── SliverAppBar (collapsible, contains product image)
        └── SliverPadding(padding: EdgeInsets.all(16))
            └── SliverList
                ├── BreadcrumbRow
                ├── SizedBox(12)
                ├── BadgeRow (if badge exists)
                ├── ProductTitle
                ├── SizedBox(8)
                ├── RatingRow
                ├── SizedBox(10)
                ├── PrimeBadge + DeliveryRow (if prime)
                ├── SizedBox(16)
                ├── TabSelector (Overview / Specs / Reviews)
                ├── SizedBox(12)
                ├── TabContent (animated cross-fade)
                ├── SizedBox(24)
                ├── BuyBox (sticky-like card)
                ├── SizedBox(32)
                ├── ReviewSummaryCard
                ├── SizedBox(16)
                ├── ReviewsList
                ├── SizedBox(32)
                ├── RelatedProductsSection
                └── SizedBox(32)
```

### 7.2 Product Image (Collapsible SliverAppBar)

**SliverAppBar specs:**
- `expandedHeight: 300dp`
- `pinned: true` (collapses to show back button + title)
- `backgroundColor: transparent`
- `flexibleSpace: FlexibleSpaceBar` with `background: ProductImageHero`

**Image container:**
- Full width, height `300dp`
- Border radius on bottom corners: `AppRadius.xl3` (24dp bottom-only)
- Background: `white5` (placeholder color)
- Image fit: `BoxFit.cover`
- Discount badge: `Positioned(bottom: 16, left: 16)` — same red badge as card
- Wishlist button: `Positioned(top: 52, right: 16)` (52 accounts for status bar)

**Collapsed state:**
- Shows: back button (left) + product name (center, truncated to 1 line) + wishlist (right)
- Background: `glassNavbar` + blur `24dp`

### 7.3 Breadcrumb Row

```
← Back  /  Electronics  /  Headphones  /  Sony WH...
```

- `← Back` is tappable: `arrowLeft` icon + "Back" text, color `primary`
- Separators: `/` in `textMuted`
- Category and subcategory: `textMuted bodySM`
- Product name: `textSecondary bodySM` truncated to `maxLines 1`
- All in a single `Row` with `Wrap` behavior or `Expanded` on last item

### 7.4 Product Title + Rating

**Title:**
- `Text` with `displayMD` (22sp 700) white
- `maxLines: 3`, `overflow: TextOverflow.ellipsis`

**Rating row:**
- Stars size `16dp`
- Rating number `priceMD primary (16sp 700)` — use accent color
- Review count `bodySM textMuted`
- Tapping the rating row scrolls to reviews section

### 7.5 Tab Content — Overview

```
[Product description paragraph]

✓ 30-hour battery life
✓ Industry-leading noise cancellation
✓ LDAC Hi-Res Audio codec
✓ Multipoint Bluetooth 5.2 connection
✓ Speak-to-Chat auto-pause
```

**Description:**
- `bodyLG textSecondary`, `lineHeight: 1.6`
- Margin bottom: `16dp`

**Highlight items:**
- Each item: `Row` with check icon + text
- Check container: `24×24dp` circle, `primarySubtle` bg, `primaryBorder` border, `borderRadius full`
- Check icon: `LucideIcons.check` size 9, `primary` color
- Text: `bodySM white70`
- Gap between icon and text: `10dp`
- Gap between rows: `8dp`

### 7.6 Tab Content — Specs

Glass table:

```
┌────────────────────────────────────┐
│ Connectivity  │  Bluetooth 5.2     │
├────────────────────────────────────┤
│ Battery       │  30 hours          │
├────────────────────────────────────┤
│ Weight        │  250g              │
└────────────────────────────────────┘
```

**Container:** glass card, `radius AppRadius.xl2`, `border`
**Each row:** `Container` with `56dp height`, `horizontal padding 16dp`
- Key: `labelMD textMuted 600`, width `100dp`
- Value: `bodyMD white80`
- Divider: `1dp border (white/5%)` between rows (not on last row)
- Alternating rows: odd rows have `white3` additional bg tint

### 7.7 Tab Content — Reviews Preview

Show first 2 reviews using the `ReviewCard` component (see 5.15).

### 7.8 Buy Box

Full-width glass card, replaces the sidebar from the web version.

```
┌───────────────────────────────────────┐
│ $279.99   ~~$399.99~~                 │
│ You save $120.00 (30%)               │
│                                       │
│ ● In Stock — Ready to ship           │
│                                       │
│ [⚡ Free Prime Delivery — Tomorrow]  │
│                                       │
│ Quantity    [−]  2  [+]              │
│                                       │
│ [    Add to Cart  🛒    ]            │  ← indigo
│ [        Buy Now         ]           │  ← amber
│                                       │
│  🔒 Secure checkout  📦 Easy returns │
└───────────────────────────────────────┘
```

**Specs:**
- Background: `glassBuyBox (rgba(13,22,53, 0.80))` + blur `20dp`
- Border: `1dp borderLight (white/10%)`
- Border radius: `AppRadius.xl3 (24dp)`
- Padding: `20dp`

**Price section:**
- Main price: `priceXL (Outfit 28sp 900)` white
- Original: same line, `bodySM white30` strikethrough
- Save text: `success (#10B981)` `labelLG 600`, `margin top 2dp`

**Stock indicator:**
- Row: `8×8dp` circle (green filled) + "In Stock — Ready to ship" `labelLG success`
- `margin: 12dp vertical`

**Prime delivery block:**
- Background: `infoSubtle`, border `infoBorder`, radius `AppRadius.xl`
- Icon: `truck` `info` color, `14sp`
- "FREE Prime Delivery" `labelMD infoBorder 600`
- "Estimated delivery: Tomorrow" `labelSM textMuted`
- `padding: 12dp`

**Quantity row:**
- Label "Quantity": `labelMD textMuted`
- Stepper component (see 5.9): aligned right or centered
- `margin: 16dp vertical`

**Buttons:**
- Add to Cart: full width, `height 48dp`, `primaryGlow` shadow, indigo gradient
- Buy Now: full width, `height 48dp`, `accentGlow` shadow, amber
- Gap: `10dp`

**Trust row (bottom):**
- Two items, centered, `gap 24dp`
- Each: small icon `12dp white35` + `labelSM white35`

### 7.9 Review Summary Section

(See component 5.16 for full specs)

**Section heading:** `displaySM (18sp 700)` white with left accent bar (amber)
**Container padding:** `20dp`

### 7.10 Full Reviews List

All reviews in `Column` with `gap 12dp`.

Each `ReviewCard` (see 5.15) is full width.

### 7.11 Related Products

Horizontal scrolling row of `ProductCard` for products in the same category (excluding current product). Max 6 items.

```
[Section header: "You May Also Like" — indigo accent bar]
[Product Card] [Product Card] [Product Card]  ← horizontal scroll
```

**Card in horizontal context:**
- Width: `200dp` fixed
- Height: `auto (approximately 280dp)`

---

## 8. Screen: Cart Drawer / Bottom Sheet

On mobile, the cart is a `DraggableScrollableSheet` or `showModalBottomSheet` that slides up from the bottom.

### 8.1 Sheet Specs

- **Initial size:** `0.65` (65% of screen height)
- **Max size:** `0.95` (95% — nearly full screen when dragged up)
- **Min size:** `0.0` (dismissible)
- **Background:** `glassDrawer (rgba(5,13,31, 0.97))` + blur `24dp`
- **Top border radius:** `AppRadius.xl3 (24dp)` top corners only
- **Top handle:** `40×4dp` capsule, `white20`, centered, `margin top 12dp`

### 8.2 Cart Header

```
Shopping Cart (2)          [X]
```

- `Row`, `padding: 20dp horizontal, 16dp top`
- Title: `displaySM (18sp 700)` white — count in parentheses
- X button: `32×32dp glass icon button`
- Bottom border: `1dp border`

### 8.3 Empty State

When cart has no items:

```
        [CartIcon 40sp white/30]

        Your cart is empty

        [Continue Shopping button]
```

- Centered vertically and horizontally
- Icon: `LucideIcons.shoppingCart` size 40, `white30`
- Text: `bodyMD textMuted`
- Button: ghost secondary, width `200dp`

### 8.4 Cart Item Row

```
┌─────────────────────────────────────────┐
│ [Image]  Sony WH-1000XM5...             │
│  64×64   $279.99                        │
│          [−] 1 [+]                      │
└─────────────────────────────────────────┘
```

- Container: `white5` bg + `border` + `AppRadius.xl2` + `padding 12dp`
- Image: `64×64dp` rounded `AppRadius.xl` `BoxFit.cover`, bg `white5`
- Product name: `bodySM white 600`, max 2 lines
- Price: `primaryLight (#818CF8)` `priceMD 700`
- Stepper: compact version — `30×30dp` buttons
- Swipe to delete: implement `Dismissible` with red background (trailing) `→ removes item`

### 8.5 Cart Footer

```
─────────────────────────────────
Subtotal           $279.99
Shipping           Free  (green)
─────────────────────────────────
[  Proceed to Checkout — $279.99  ]
[       Continue Shopping          ]
```

- Container: `padding 20dp`, `border-top 1dp border`
- Subtotal row: `bodyMD textMuted` + `bodyMD white bold`
- Shipping row: `bodyMD textMuted` + `labelLG success`
- Gap: `6dp` between rows
- `Divider` `1dp border` between rows and buttons
- Checkout button: full width `48dp` **amber** CTA
- Continue Shopping: full width `44dp` ghost button

---

## 9. Navigation Architecture

### 9.1 Stack-Based Navigation (No Bottom Nav)

The app uses a simple `Navigator` with named routes or a `StatefulWidget` with page state. For MVP:

```dart
// lib/main.dart → home: AppShell()

class AppShell extends StatefulWidget { ... }
class _AppShellState extends State<AppShell> {
  String _currentPage = 'home';       // 'home' | 'product'
  Product? _selectedProduct;
  List<CartItem> _cart = [];
  bool _cartOpen = false;

  void _navigateToProduct(Product p) { ... }
  void _navigateBack() { ... }
  void _addToCart(Product p) { ... }
  void _updateCartQty(int id, int qty) { ... }
}
```

### 9.2 Transitions

**Home → Product:**
- `FadeTransition` combined with `SlideTransition` (slide from bottom, `0,0.08 → 0,0`)
- Duration: `300ms`, `Curves.easeOutCubic`

**Product → Home:**
- Reverse of above

**Cart opening:**
- `showModalBottomSheet` with `isScrollControlled: true`
- Builds with `DraggableScrollableSheet`
- Background overlay: `rgba(0,0,0, 0.50)` with `BackdropFilter blur 8dp`

### 9.3 Scroll Behavior

- `CustomScrollView` with `physics: BouncingScrollPhysics()` for iOS-like elastic scroll
- `SliverAppBar` in product detail should have `floating: false, pinned: true`
- Hide scrollbar: `ScrollbarTheme.of(context).copyWith(thumbVisibility: MaterialStateProperty.all(false))`

---

## 10. Animations & Interactions

### 10.1 Card Hover/Press Animation

```dart
// Wrap ProductCard in AnimatedContainer or GestureDetector + Transform
GestureDetector(
  onTapDown: (_) => setState(() => _isPressed = true),
  onTapUp: (_) => setState(() => _isPressed = false),
  onTapCancel: () => setState(() => _isPressed = false),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOut,
    transform: Matrix4.translationValues(
      0, _isPressed ? 0 : 0, 0  // on mobile, use scale instead of translateY
    )..scale(_isPressed ? 0.97 : 1.0),
    child: ProductCard(...),
  ),
)
```

### 10.2 Button Press Scale

```dart
// All primary and CTA buttons
AnimatedScale(
  scale: _isPressed ? 0.97 : 1.0,
  duration: Duration(milliseconds: 150),
  child: ElevatedButton(...),
)
```

### 10.3 Image Scale on Hover (Card)

Use `AnimatedScale` on the `Image` widget within the card:
- Default: `1.0`
- On card tap-down: `1.05`
- Duration: `500ms`, `Curves.easeOut`

### 10.4 Tab Switch Animation

```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 250),
  transitionBuilder: (child, animation) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 0.04), end: Offset.zero)
        .animate(animation),
      child: child,
    ),
  ),
  child: tabContent, // key: ValueKey(activeTab)
)
```

### 10.5 Cart Item Add Animation

When user taps "Add to Cart":
1. Show `SnackBar` or `ScaffoldMessenger` toast at bottom
2. Cart icon badge count animates: old count fades out up, new count fades in down
3. Cart icon briefly scales to `1.15` then back to `1.0`

**Toast style:**
- Custom `SnackBar` widget
- Background: `glassBuyBox` + blur
- Border: `border`
- Border radius: `AppRadius.xl2`
- Duration: `3 seconds`
- Shows: product name (truncated) + price + "View Cart" action button in `primary`

### 10.6 Wishlist Heart Toggle

```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 200),
  child: liked
    ? Icon(LucideIcons.heart, color: danger, key: ValueKey('liked'))
    : Icon(LucideIcons.heart, color: white50, key: ValueKey('unliked')),
)
```

Also: brief scale pulse `1.0 → 1.3 → 1.0` when toggling to liked state.

### 10.7 Hero Slide Indicator

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: isActive ? 28 : 6,
  height: 6,
  decoration: BoxDecoration(
    color: isActive ? Colors.white : Colors.white30,
    borderRadius: BorderRadius.circular(3),
  ),
)
```

### 10.8 Rating Bar Fill Animation

```dart
// Animate bars in when reviews section scrolls into view
// Use AnimationController + Tween on width factor
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: percentage / 100),
  duration: Duration(milliseconds: 800),
  curve: Curves.easeOutCubic,
  builder: (_, value, __) => FractionallySizedBox(widthFactor: value, ...),
)
```

---

## 11. Flutter Implementation Notes

### 11.1 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  lucide_icons: ^0.0.4
  cached_network_image: ^3.3.0  # for network images with placeholder
  flutter_staggered_grid_view: ^0.7.0  # optional for masonry grid
  shimmer: ^3.0.0  # loading skeletons

dev_dependencies:
  flutter_lints: ^3.0.0
```

### 11.2 Image Loading

Use `CachedNetworkImage` for all product images:

```dart
CachedNetworkImage(
  imageUrl: product.image,
  fit: BoxFit.cover,
  placeholder: (context, url) => Container(
    color: AppColors.white5,
    child: shimmerEffect(), // optional shimmer
  ),
  errorWidget: (context, url, error) => Container(
    color: AppColors.white5,
    child: Icon(LucideIcons.image, color: AppColors.textMuted),
  ),
)
```

### 11.3 BackdropFilter Performance

`BackdropFilter` can be expensive. Use `RepaintBoundary` around heavy blur areas. For the navbar, consider using a single `BackdropFilter` that covers the full navbar vs individual widgets.

```dart
// Wrap entire navbar in one BackdropFilter
ClipRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
    child: Container(
      color: AppColors.glassNavbar,
      child: navbarContent,
    ),
  ),
)
```

### 11.4 Theme Configuration

```dart
// lib/core/theme/app_theme.dart
ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: Colors.transparent, // background set via Container gradient
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.card,
    error: AppColors.danger,
  ),
  textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
  fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
  useMaterial3: true,
  // Remove all default Material ink splashes — use custom press animations
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
  hoverColor: Colors.transparent,
);
```

### 11.5 State Management

For a clean implementation, use `Provider` or `Riverpod`:

```dart
// CartNotifier
class CartNotifier extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;
  int get count => _items.fold(0, (sum, i) => sum + i.quantity);
  double get total => _items.fold(0, (sum, i) => sum + i.product.price * i.quantity);

  void addItem(Product p) { ... notifyListeners(); }
  void updateQty(int id, int qty) { ... notifyListeners(); }
  void removeItem(int id) { ... notifyListeners(); }
}
```

### 11.6 Safe Area & Padding

- Use `SafeArea` wrapper on all screens
- Navbar: `padding top: MediaQuery.of(context).padding.top`
- Bottom sheet: `padding bottom: MediaQuery.of(context).padding.bottom + 16`
- Content scroll: add `bottom padding` equal to safe area

### 11.7 Product Data Model

```dart
// lib/data/models/product.dart
class Product {
  final int id;
  final String name;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String image;
  final String category;
  final String subcategory;
  final String? badge;  // 'Best Seller' | 'Deal' | 'New' | 'Limited' | null
  final String description;
  final List<String> highlights;
  final Map<String, String> specs;
  final List<Review> reviews;
  final bool inStock;
  final bool prime;

  int get discountPercent => originalPrice != null
    ? ((1 - price / originalPrice!) * 100).round()
    : 0;

  double get savings => originalPrice != null ? originalPrice! - price : 0;
}
```

### 11.8 Glassmorphism Gotchas in Flutter

1. **`BackdropFilter` only blurs what's drawn behind it.** If you nest it in a `Stack`, make sure the content to be blurred is a sibling widget rendered *before* the blur widget.

2. **Performance:** Limit nested `BackdropFilter` widgets. Aim for 1-2 active blur filters on screen at a time. The navbar blur and the card blur can coexist, but adding blur to every card in a long scroll list will tank performance. Consider using semi-transparent cards without blur on scroll content, and reserving blur for fixed elements (navbar, bottom sheets, hero).

3. **Simulator vs Device:** Blur effects may not render in debug mode on some simulators. Always test on physical device.

4. **`ClipRRect` is required before `BackdropFilter`** — if you skip it, the blur will leak outside the container bounds.

5. **Opaque background for gradient orbs:** The orbs use `RadialGradient` with `Colors.transparent` at edges. This works on most devices but ensure the root `Scaffold` `backgroundColor` is set to `Colors.transparent` so the `Container` gradient shows through.

### 11.9 Responsive Considerations

While this is a mobile-first design, consider:

- **Small phones (< 360dp):** Reduce card padding to `10dp`, font sizes by `1-2sp`
- **Large phones / tablets (> 600dp):** Switch product grid to `crossAxisCount: 3`, increase hero height to `320dp`
- **Use `LayoutBuilder` or `MediaQuery.of(context).size.width` to adapt**

---

## Appendix A — Full Color Reference Table

| Token | Hex | ARGB | Usage |
|-------|-----|------|-------|
| background | `#050D1F` | `FF050D1F` | Page bg |
| card | `#0D1635` | `FF0D1635` | Card solid |
| glassCard | — | `990D1635` | Glass cards |
| glassNavbar | — | `D9050D1F` | Navbar glass |
| primary | `#6366F1` | `FF6366F1` | Buttons, links |
| primaryLight | `#818CF8` | `FF818CF8` | Hover |
| accent | `#F59E0B` | `FFF59E0B` | CTA, price, stars |
| success | `#10B981` | `FF10B981` | In-stock, savings |
| danger | `#EF4444` | `FFEF4444` | Discount, delete |
| info | `#0EA5E9` | `FF0EA5E9` | Prime, info |
| violet | `#8B5CF6` | `FF8B5CF6` | Limited badge |
| textPrimary | `#E2E8F5` | `FFE2E8F5` | Main text |
| textSecondary | `#B8C4DD` | `FFB8C4DD` | Sub text |
| textMuted | `#7A8AAA` | `FF7A8AAA` | Captions |
| border | — | `14FFFFFF` | Hairline (8%) |
| borderLight | — | `33FFFFFF` | Hover border (20%) |
| starFilled | `#FBBF24` | `FFFBBF24` | Rating stars |

---

## Appendix B — Screen Dimensions Reference

| Element | Height | Width | Notes |
|---------|--------|-------|-------|
| Navbar | 56dp | full | + safe area top |
| Category bar | 40dp | full | |
| Hero banner | 260dp | full − 32dp | 16dp side margins |
| Product card | ~280dp | (screen−44dp)/2 | 2-col grid, 12dp gap |
| Deal card | auto | 148dp | horizontal scroll |
| Category tile | square | (screen−76dp)/4 | 4-col grid, 10dp gap |
| Feature tile | 64dp | (screen−42dp)/2 | 2-col, 10dp gap |
| Cart sheet | 65–95% | full | bottom sheet |
| Buy box | auto | full | padding 16dp |
| Rating summary | auto | full | in detail page |

---

*End of specification. Build every screen, component, and interaction described above for a complete, production-quality Flutter mobile e-commerce application matching the NovaShop glassmorphism aesthetic.*
