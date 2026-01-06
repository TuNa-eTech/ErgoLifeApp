# Ergo-Coach Animations

This directory contains Lottie animation files for the Ergo-Coach feature.

## Required Files

Each task type needs a corresponding Lottie JSON animation file:

1. `vacuuming.json` - Vacuum cleaning animation
2. `mopping.json` - Mopping floor animation
3. `dishwashing.json` - Washing dishes animation
4. `toilet_cleaning.json` - Cleaning toilet animation
5. `bed_making.json` - Making bed animation
6. `laundry.json` - Doing laundry animation
7. `shopping.json` - Grocery shopping animation
8. `cooking.json` - Cooking animation
9. `trash.json` - Taking out trash animation
10. `pet_care.json` - Pet care animation

## How to Get Animations

### Option 1: Download from LottieFiles (Recommended)
1. Visit https://lottiefiles.com
2. Search for relevant animations (e.g., "cleaning", "housework")
3. Download as JSON format
4. Rename to match the filenames above
5. Place in this directory

### Option 2: Generate Custom Animations
- Use Adobe After Effects with Bodymovin plugin
- Create or commission custom animations
- Export as Lottie JSON

### Option 3: Placeholder (For Development)
For now, we can use a generic animation for all tasks until proper animations are sourced.

## File Naming Convention

- All lowercase
- Underscore separated
- `.json` extension
- Match task type exactly

## Animation Requirements

- **Duration:** 2-4 seconds
- **Loop:** Should be loopable
- **Size:** < 100KB per file (optimized)
- **Format:** Lottie JSON (.json)
- **Style:** Clean, minimal, educational
- **Focus:** Show proper ergonomic posture

## Integration

These animations are loaded by:
- `lib/ui/widgets/ergo_coach_overlay.dart`
- Shown before starting each task type
- Auto-skip after user has seen 3 times per task

## Next Steps

1. Source/download appropriate animations
2. Test animations in overlay
3. Optimize file sizes if needed
4. Add to version control
