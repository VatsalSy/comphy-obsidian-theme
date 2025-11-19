# CoMPhy Gruvbox

A Gruvbox-inspired theme for [Obsidian](https://obsidian.md) with academic and research customizations.

![Screenshot](screenshot.png)

## Features

### Color Palette
- **Gruvbox-inspired colors** with dark and light mode support
- **Durham Purple accent** (#B347BF) for a distinctive academic feel
- Carefully tuned contrast for extended reading sessions

### Typography
- **Hack Nerd Font** for consistent monospace rendering
- Custom header colors (H1-H6 each with unique Gruvbox colors)
- Optimized font weights for readability

### File Navigation
- **Color-coded folder icons** for quick visual identification
- Custom emoji-based folder styling:
  - 📜 Scripts
  - ✍️ Blog
  - 📘 Code-Documentation
  - 📝 Lecture-Notes
  - 🎤 Talks
  - ✨ Wish-List
  - 📚 ReadWise
- Special styling for Conference and Journal Club folders

### Code & Syntax
- Language-specific code fence styling
- Syntax highlighting optimized for Gruvbox colors
- Inline code with distinct background

### Plugin Support
- Calendar Plugin
- Prominent Star Plugin
- Block Reference Counter
- Sliding Panes
- Graph View with custom node colors

### Additional Features
- Stylish blockquotes and callouts
- Custom highlights (including Templater-based)
- Banded table rows
- Image hover effects
- Clutter-free mode option

## Installation

### From Community Themes
1. Open Obsidian Settings
2. Go to **Appearance** → **Themes**
3. Click **Manage** and search for "CoMPhy Gruvbox"
4. Click **Install and use**

### Manual Installation
1. Download `theme.css` and `manifest.json` from this repository
2. Create a folder called `CoMPhy Gruvbox` in your vault's `.obsidian/themes/` directory
3. Copy both files into the folder
4. Enable the theme in Obsidian Settings → Appearance → Themes

## Screenshots

### Dark Mode
*Coming soon*

### Light Mode
*Coming soon*

## Customization

The theme uses CSS variables that you can override in a CSS snippet:

```css
.theme-dark {
  --background-primary: #1a1a1a;
  --accent: #B347BF;
}

.theme-light {
  --background-primary: #f9f5d7;
  --accent: #B347BF;
}
```

## Recommended Fonts

This theme is optimized for [Hack Nerd Font](https://www.nerdfonts.com/font-downloads). Install it for the best experience, especially for file icons and special characters.

## Credits

- Inspired by the [Gruvbox](https://github.com/morhetz/gruvbox) color scheme by morhetz
- Built for the [CoMPhy Lab](https://comphy-lab.org) research workflow

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**Vatsal Sanjay**
[vatsal.comphy-lab.org](https://vatsal.comphy-lab.org)

## Contributing

Issues and pull requests are welcome! Please feel free to contribute improvements or report bugs.
