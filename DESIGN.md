---
name: Sketchbook Journal
colors:
  surface: '#fbf9f5'
  surface-dim: '#dbdad6'
  surface-bright: '#fbf9f5'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3ef'
  surface-container: '#efeeea'
  surface-container-high: '#eae8e4'
  surface-container-highest: '#e4e2de'
  on-surface: '#1b1c1a'
  on-surface-variant: '#444748'
  inverse-surface: '#30312e'
  inverse-on-surface: '#f2f0ed'
  outline: '#747878'
  outline-variant: '#c4c7c7'
  surface-tint: '#5f5e5e'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1c1b1b'
  on-primary-container: '#858383'
  inverse-primary: '#c8c6c5'
  secondary: '#596400'
  on-secondary: '#ffffff'
  secondary-container: '#d5ec00'
  on-secondary-container: '#5d6800'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#3d0023'
  on-tertiary-container: '#d25993'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e5e2e1'
  primary-fixed-dim: '#c8c6c5'
  on-primary-fixed: '#1c1b1b'
  on-primary-fixed-variant: '#474746'
  secondary-fixed: '#d8ef00'
  secondary-fixed-dim: '#bdd200'
  on-secondary-fixed: '#1a1e00'
  on-secondary-fixed-variant: '#434b00'
  tertiary-fixed: '#ffd9e5'
  tertiary-fixed-dim: '#ffb0cf'
  on-tertiary-fixed: '#3d0023'
  on-tertiary-fixed-variant: '#841954'
  background: '#fbf9f5'
  on-background: '#1b1c1a'
  surface-variant: '#e4e2de'
typography:
  headline-lg:
    fontFamily: beVietnamPro
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-md:
    fontFamily: beVietnamPro
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  body-lg:
    fontFamily: beVietnamPro
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: beVietnamPro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-sm:
    fontFamily: beVietnamPro
    fontSize: 14px
    fontWeight: '500'
    lineHeight: '1.4'
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  baseline: 24px
  gutter: 16px
  margin: 24px
  sticker-padding: 12px
---

## Brand & Style
The design system is built upon the intimate, tactile experience of a traveler’s personal sketchbook. It avoids the clinical precision of modern digital interfaces in favor of an organic, "perfectly imperfect" aesthetic. The personality is nostalgic, creative, and deeply personal, evoking the emotional response of flipping through a cherished journal.

The style is primarily **Tactile and Skeuomorphic**, utilizing physical metaphors like paper textures, ink bleeds, and sticker overlays. It incorporates elements of **Brutalism** through its raw, unpolished borders and honest expression of "hand-made" digital artifacts. The user should feel as though they are interacting with a physical object where every line was drawn specifically for them.

## Colors
The palette is rooted in the high-contrast relationship between black ink and off-white paper. 

- **Background**: The primary canvas is an off-white, warm-toned paper texture (`#FDFBF7`).
- **Ink (Primary)**: A deep, slightly charcoal black (`#1A1A1A`) is used for all "drawn" elements, text, and structural lines to mimic a felt-tip pen.
- **Highlighter (Secondary/Tertiary)**: Accent colors are applied as semi-transparent "splashes" or "scribbles." A vibrant neon yellow (`#E6FF00`) acts as the primary highlighter for emphasis, while a soft pencil pink (`#FF7EB9`) provides secondary accents.
- **Paper Lines**: Horizontal parallel lines should be rendered in a faint, cool grey to simulate a standard school notebook layout.

## Typography
This design system utilizes **beVietnamPro** for its warm, approachable, and slightly casual character. While the technical implementation uses a clean sans-serif to ensure legibility across all devices, the styling must prioritize a "written" feel. 

Headlines should be rendered with slight, randomized rotations (between -1 and 1 degree) to break the digital grid. Body text should be aligned to the horizontal notebook lines of the background where possible. For an authentic traveler's look, all text should have a very subtle "ink bleed" effect (a soft 0.5px blur) to mimic pen on fiber.

## Layout & Spacing
The layout follows a **Fixed Grid** model that centers content within the "pages" of the notebook. The rhythm is dictated by the background's horizontal lines, with a 24px baseline that ensures text sits comfortably on the rules.

Spacing is intentionally loose and "human." Elements are not perfectly aligned; they should feature "planned randomness." For example, containers should have varying margins to simulate someone drawing boxes by hand. Margins are generous to prevent the design from feeling cluttered, maintaining the airy feel of a fresh sketchbook page.

## Elevation & Depth
Depth in this design system is achieved through physical layering rather than digital shadows. 

1.  **Base Layer**: The lined paper.
2.  **Ink Layer**: Hand-drawn borders, text, and doodles that appear to be part of the paper.
3.  **Sticker Layer**: "Souvenirs" and high-priority call-to-actions that sit on top of the ink. These use a flat, white "die-cut" border (2-3px) and a very tight, dark, low-opacity shadow to suggest they are physically stuck to the page.
4.  **Highlighter Layer**: Transparent color overlays that sit between the paper and the ink, allowing the lines and text to show through.

## Shapes
Every shape in the design system must avoid perfect geometric primitives. 

- **Borders**: All containers use a "sketchy" border—a multi-pass line effect where 2-3 slightly different paths overlap to create a hand-drawn look.
- **Corners**: While the base `roundedness` is set to 1, this should be interpreted as a "wobbly" corner rather than a mathematical radius.
- **Icons**: Icons are doodle-style, featuring open paths, overshot lines (where the line goes slightly past the corner), and varying stroke weights.

## Components

### Buttons
Buttons should look like hand-drawn rectangles. The "Primary" state is a rectangle with a thick ink border and a "colored pencil" scribble fill of the secondary color. The text is centered but may be slightly tilted.

### Souvenirs ()
Souvenirs are treated as stickers. They feature a thick white border (the die-cut) around their entire perimeter. They are always slightly rotated (between -3 and 3 degrees) to look like they were placed by hand.

### Progress Bar
The track is a simple hand-drawn long rectangle. The progress fill is a dense, "hasty" colored pencil scribble in the accent color, leaving some white space visible within the fill to maintain the textured look.

### Scroller (Alphabet)
Instead of a traditional scrollbar, a horizontal string of hand-drawn capital letters A-Z sits at the bottom of the view. The current position is indicated by a rough, hand-drawn ink circle around the corresponding letter.

### Input Fields
Inputs are indicated by a simple hand-drawn underline rather than a box. When focused, a "highlighter" splash appears behind the text area.

### Checkboxes
Small, hand-drawn squares. When "checked," an "X" is drawn inside, with the lines intentionally extending slightly outside the box boundaries.