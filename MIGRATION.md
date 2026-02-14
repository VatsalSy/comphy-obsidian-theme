# Migration Guide: Legacy Theme -> Modular Rewrite

This rewrite deprecates duplicated legacy selectors and moves to a tokenized modular architecture.

## Scope

Preserved:
- Folder-structure semantics (`_`, `0-`, `1-`, `2-`, `3-`, `Projects`, `Z_Archive`, key aliases)
- Broad plugin coverage (Dataview, Calendar, Graph, popovers, utility styling)
- Purple accent identity, now anchored to `#68236D`

Deprecated:
- Repeated selector blocks with conflicting overrides
- Overly specific one-off path rules that duplicated bucket behavior
- High-noise icon/emoji scatter

## File Architecture Mapping

| Legacy location | New location |
|---|---|
| Mixed tokens in `theme.css` root blocks | `src/theme/tokens.css` |
| Base typography/layout spread across many sections | `src/theme/foundations.css` |
| Buttons/tags/code/tables scattered and duplicated | `src/theme/components.css` |
| Repeated folder path rules in multiple places | `src/theme/navigation.css` |
| Dataview/Calendar/Graph/plugin snippets merged ad hoc | `src/theme/plugins.css` |
| Focus/motion/print tweaks mixed in main file | `src/theme/accessibility.css` |

## Folder Structure Compatibility Map

| Existing pattern | New handling |
|---|---|
| `_...` folders | Preserved via underscore bucket gradient + semantic icon |
| `0-...` | Preserved via bucket-0 style |
| `1-...` | Preserved via bucket-1 style |
| `2-...` | Preserved via bucket-2 style |
| `3-...` and `Z_Archive...` | Preserved via archive bucket style |
| `Projects...` | Preserved as dedicated project accent bucket |
| `_LinkStubs...` | Preserved as dedicated blended bucket |
| `Readwise/readwise/_ReadWise` | Preserved via alias group |
| `Scripts/scripts/_scripts` | Preserved via alias group |
| `Conference/...` and `conference-and-journal-club/...` | Preserved via alias group |

## Behavioral Changes

1. Image hover zoom has been removed for readability and motion safety.
2. Folder icon system is simplified and more consistent.
3. Duplicate plugin blocks were consolidated to one adapter layer.
4. Accent usage is now consistent through semantic variables.

## If You Need Legacy-Specific Styling

Add a personal snippet in your vault for niche customizations instead of modifying generated `theme.css`.

Example override snippet:

```css
/* .obsidian/snippets/local-overrides.css */
.nav-folder-title[data-path^="MyLegacyFolder"] {
  background: linear-gradient(140deg, #c07497 0%, #9f4f76 100%);
  color: #fff8ff;
}
```

## Build Workflow

Edit modular source files under `src/theme/`, then regenerate:

```bash
bash scripts/build-theme.sh
```
