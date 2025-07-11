# Aurora Newsletter Template System

A maintainable template system for generating Aurora platform newsletters. This system separates content from presentation using JSON data files and HTML templates to enable consistent, professional communications about cloud-native government initiatives.

## Overview

This system addresses the challenge of maintaining consistent newsletter formatting while allowing easy content updates across different topics and initiatives. Content editors work with structured JSON files that are processed into final HTML via a Node.js build script. Each edition can focus on different themes while maintaining Aurora branding and Government of Canada visual identity standards.

## Project Structure

```
aurora-newsletter/
├── template.html                  # Master HTML template with placeholders
├── content/                       # Newsletter content as JSON files
│   └── 2025-06-gc-artifacts.json # Current edition content
├── build.js                       # Build script (Node.js)
├── package.json                   # Project dependencies and scripts
├── assets/                        # Organized asset files
│   ├── background.jpeg           # Background image
│   ├── canada-logo.svg          # Canada wordmark
│   ├── ssc-logo.svg             # SSC logo (deprecated)
│   └── ssc-text.svg             # SSC text logo
├── 2025-06-gc-artifacts.html     # Current generated newsletter
└── inline-images.sh              # Image processing utility
```

## Getting Started

### Prerequisites
- Node.js 14 or higher
- Python 3 (for local server)

### Build a Newsletter

```bash
# Build the current edition
npm run build:current

# Build any content file
node build.js content/your-file.json

# Build and serve locally for testing
npm run dev
```

The generated HTML appears in the root directory and can be viewed at `http://localhost:8000/[edition-name].html`

### Local Development

```bash
# Start local server only
npm run serve

# Then navigate to http://localhost:8000/2025-06-gc-artifacts.html
```

## Creating New Editions

1. **Copy existing content file**:
   ```bash
   cp content/2025-06-gc-artifacts.json content/2025-07-cloud-security.json
   ```

2. **Update the content**:
   - Change `meta.edition` to a unique identifier (e.g., "2025-07-cloud-security")
   - Update `meta.title` to reflect new topic (e.g., "Aurora Newsletter - Cloud Security")
   - Update `meta.date` in YYYY-MM-DD format (e.g., "2025-07-15")
   - Modify sections for new theme while keeping Aurora branding consistent

3. **Build the edition**:
   ```bash
   node build.js content/2025-07-cloud-security.json
   ```

4. **Test locally**:
   ```bash
   npm run serve
   # Navigate to http://localhost:8000/2025-07-cloud-security.html
   ```

## Content Structure

Content files use JSON with the following top-level structure:

- `meta`: Edition metadata (title, date in YYYY-MM-DD format, identifier)
- `assets`: File paths for logos and images
- `header`: Main newsletter header content
- `hero`: Hero section content
- `footer`: Footer information and contacts
- `english`: English language sections array
- `french`: French language sections array

### Section Types

The system supports these predefined section types:

- **main_announcement**: Opening section with highlight boxes and statistics
- **technology_stack**: Feature cards in grid layout
- **container_images**: Code blocks for technical content
- **implementation**: Phase-based implementation guides
- **support**: Resource lists with contact information
- **cta**: Call-to-action buttons and links
- **ml_capabilities**: JFrog ML features with resources and links
- **aurora**: Special formatting for Aurora project content

### Content Guidelines

- Use HTML tags within content for formatting (`<strong>`, `<br>`, etc.)
- Markdown-style links `[text](url)` are automatically converted to HTML
- Contact emails should be complete addresses
- URLs should include protocol (`https://`)

## Template System

The build process replaces placeholders in `template.html`:

- `{{TITLE}}` - Page title
- `{{SUBTITLE}}` - Newsletter subtitle (e.g., "GC Secure Artifacts")
- `{{TAGLINE}}` - Subtitle tagline (e.g., "Strengthening GC's Software Supply Chain")
- `{{HERO_TITLE}}` - Hero section heading
- `{{HERO_DESCRIPTION}}` - Hero section description
- `{{ENGLISH_CONTENT}}` - Generated English sections
- `{{FRENCH_CONTENT}}` - Generated French sections

## Bilingual Support

Both English and French content use the same section structure. If French content is incomplete, the system displays a placeholder message. Each language section array is processed independently with a JavaScript-powered language toggle.

## Aurora Branding and Government Standards

The template maintains Aurora platform identity within Government of Canada visual standards:

- Aurora Newsletter branding with SSC organizational support
- Uses official SSC and Canada logos in header
- Preserves approved color palette (magenta #C91CB3, indigo #4530A8)
- Maintains proper bilingual headers and footers
- Follows accessibility guidelines for contrast and typography
- Footer identifies Aurora as the platform delivering the newsletter

## Distribution Workflow

1. **Generate**: Build HTML from template and content
2. **Review**: Test locally using the development server
3. **Host**: Deploy HTML to web server or GitHub Pages
4. **Distribute**: Send email summary with link to full newsletter

## Development

### Adding New Section Types

1. Add the section to your content JSON
2. Implement a generator method in `build.js`:
   ```javascript
   generateCustomSection(section) {
       return `<div class="content-section">
           <h2>${section.title}</h2>
           <p>${section.content}</p>
       </div>`;
   }
   ```
3. Add the case to the switch statement in `generateContentSections()`

Example: The `ml_capabilities` section includes recording links, feature lists, additional content paragraphs, and resource links with automatic `target="_blank"` for external URLs.

### Modifying Styles

Edit the CSS within `template.html`. Test changes across different screen sizes and ensure compliance with Government of Canada branding guidelines.

### Build Script Options

```bash
# Display help
node build.js --help

# Build with custom output path
node build.js content/file.json custom-name.html
```


## File Naming Conventions

- Content files: `YYYY-MM-topic.json` (e.g., `2025-01-kubernetes.json`, `2025-03-devops-tools.json`)
- Generated files: Match content file basename (e.g., `2025-01-kubernetes.html`)
- Asset files: Descriptive names, web-safe formats
- Edition identifiers: Use topic-based naming for clarity

## Contributing

When adding content or modifying the system:

1. Test builds locally before committing
2. Verify bilingual content renders correctly
3. Check responsive behavior on different screen sizes
4. Maintain consistent JSON structure across editions
5. Follow existing placeholder naming patterns
6. Ensure Government of Canada branding compliance

## Support

- Technical issues: Create repository issue
- Content guidance: aurora-aurore@ssc-spc.gc.ca
- Aurora project: https://aurora.gccloudone.ca
