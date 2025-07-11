#!/usr/bin/env node

const fs = require('fs');
const juice = require('juice');

/**
 * Aurora Newsletter Template Builder
 * 
 * Builds newsletter HTML from template and content JSON
 * Usage: node build.js [content-file] [output-file]
 * 
 * Example: node build.js content/2024-12-gc-artifacts.json output/newsletter.html
 */

class NewsletterBuilder {
    constructor(isEmail = false) {
        this.templatePath = isEmail ? './template-email.html' : './template.html';
        this.isEmail = isEmail;
    }

    /**
     * Load and parse JSON content file
     */
    loadContent(contentPath) {
        try {
            const content = fs.readFileSync(contentPath, 'utf8');
            return JSON.parse(content);
        } catch (error) {
            console.error(`Error loading content file: ${error.message}`);
            process.exit(1);
        }
    }

    /**
     * Load template file
     */
    loadTemplate() {
        try {
            return fs.readFileSync(this.templatePath, 'utf8');
        } catch (error) {
            console.error(`Error loading template: ${error.message}`);
            process.exit(1);
        }
    }

    /**
     * Generate content sections from JSON data
     */
    generateContentSections(sections) {
        let sectionsToProcess = sections;
        if (this.isEmail) {
            sectionsToProcess = sections.slice(0, 1);
        }

        let html = sectionsToProcess.map(section => {
            switch (section.type) {
                case 'main_announcement':
                    return this.generateMainAnnouncement(section);
                case 'technology_stack':
                    return this.generateTechnologyStack(section);
                case 'container_images':
                    return this.generateContainerImages(section);
                case 'implementation':
                    return this.generateImplementation(section);
                case 'support':
                    return this.generateSupport(section);
                case 'cta':
                    return this.generateCTA(section);
                case 'aurora':
                    return this.generateAurora(section);
                case 'ml_capabilities':
                    return this.generateMLCapabilities(section);
                default:
                    return this.generateGenericSection(section);
            }
        }).join('\n\n');

        if (this.isEmail) {
            html += `
<div class="content-section">
    <p style="text-align: center;">
        <a href="https://simardeep1792.github.io/aurora-newsletter/2025-06-gc-artifacts.html">Read the full version of the newsletter</a>
    </p>
</div>`;
        }

        return html;
    }

    /**
     * Generate main announcement section
     */
    generateMainAnnouncement(section) {
        let html = `<div class="content-section">
    <h2>${section.title}</h2>
    <p>${section.content}</p>`;

        if (section.highlight_box) {
            html += `\n\n    <div class="highlight-box">
        <h3>${section.highlight_box.title}</h3>
        <ul>
            ${section.highlight_box.items.map(item => `<li>${item}</li>`).join('\n            ')}
        </ul>
    </div>`;
        }

        if (section.stats) {
            html += `\n\n    <div class="stats-section">
        <h3>${section.stats.title}</h3>
        <div class="stats-grid">
            ${section.stats.items.map(stat => 
                `<div class="stat-item">
                <span class="stat-number">${stat.number}</span>
                <span class="stat-label">${stat.label}</span>
            </div>`
            ).join('\n            ')}
        </div>
    </div>`;
        }

        html += `\n</div>`;
        return html;
    }

    /**
     * Generate technology stack section
     */
    generateTechnologyStack(section) {
        let html = `<div class="content-section">
    <h2>${section.title}</h2>`;

        section.subsections.forEach(subsection => {
            html += `\n\n    <h3>${subsection.title}</h3>
    <p>${subsection.content}</p>

    <div class="feature-grid">
        ${subsection.feature_cards.map(card => 
            `<div class="feature-card">
            <h4>${card.title}</h4>
            <p>${card.content}</p>
        </div>`
        ).join('\n        ')}
    </div>`;
        });

        html += `\n</div>`;
        return html;
    }

    /**
     * Generate container images section
     */
    generateContainerImages(section) {
        return `<div class="content-section">
    <h2>${section.title}</h2>
    <p>${section.content}</p>

    <div class="code-block">
        ${section.code_block.map(code => `<p>${code}</p>`).join('\n        ')}
    </div>
</div>`;
    }

    /**
     * Generate implementation section
     */
    generateImplementation(section) {
        let html = `<div class="content-section">
    <h2>${section.title}</h2>
    <p>${section.content}</p>`;

        section.phases.forEach(phase => {
            html += `\n\n    <h4>${phase.title}</h4>
    <p>${phase.content}</p>`;
        });

        html += `\n</div>`;
        return html;
    }

    /**
     * Generate support section
     */
    generateSupport(section) {
        let html = `<div class="content-section">
    <h2>${section.title}</h2>
    <p>${section.content}</p>

    <ul>
        ${section.list_items.map(item => `<li>${item}</li>`).join('\n        ')}
    </ul>`;

        if (section.contact) {
            html += `\n\n    <p><strong>Contact:</strong> ${section.contact.text} <a href="mailto:${section.contact.email}">${section.contact.email}</a></p>`;
        }

        html += `\n</div>`;
        return html;
    }

    /**
     * Generate CTA section
     */
    generateCTA(section) {
        return `<div class="cta-section">
    <h3>${section.title}</h3>
    <p>${section.content}</p>
    ${section.buttons.map(button => 
        `<a href="${button.url}" class="cta-button">${button.text}</a>`
    ).join('\n    ')}
</div>`;
    }

    /**
     * Generate Aurora section
     */
    generateAurora(section) {
        let html = `<!-- Aurora Section -->
<div class="aurora-section">
    <h2>${section.title}</h2>
    <p>${this.processMarkdownLinks(section.content)}</p>
    
    <h3>${section.involvement.title}</h3>
    <ul>
        ${section.involvement.items.map(item => `<li>${item}</li>`).join('\n        ')}
    </ul>
    
    <p>${this.processMarkdownLinks(section.community)}</p>
    
    <div class="aurora-cta">
        <p><strong>${section.feedback.text}</strong></p>
        ${section.feedback.buttons.map(button => 
            `<a href="${button.url}" target="_blank">${button.text}</a>`
        ).join('\n        ')}
    </div>
</div>`;
        return html;
    }

    /**
     * Generate ML capabilities section
     */
    generateMLCapabilities(section) {
        let html = `<div class="content-section">
    <h2>${section.title}</h2>
    <p>${section.content}</p>`;

        if (section.recording_links) {
            html += `\n    <ul>
        ${section.recording_links.map(link => 
            `<li><strong>${link.text}:</strong> <a href="${link.url}" target="_blank">${link.title}</a></li>`
        ).join('\n        ')}
    </ul>`;
        }

        if (section.features) {
            html += `\n    <p>${section.features.intro}</p>
    <ul>
        ${section.features.items.map(item => `<li>${item}</li>`).join('\n        ')}
    </ul>`;
        }

        if (section.additional_content) {
            section.additional_content.forEach(content => {
                html += `\n    <p>${content}</p>`;
            });
        }

        if (section.resources) {
            html += `\n    <h3>${section.resources.title}</h3>
    <p>${section.resources.intro}</p>
    <ul>
        ${section.resources.links.map(link => 
            `<li><a href="${link.url}" target="_blank">${link.text}</a></li>`
        ).join('\n        ')}
    </ul>`;
        }

        html += `\n</div>`;
        return html;
    }

    /**
     * Generate generic section
     */
    generateGenericSection(section) {
        return `<div class="content-section">
    <h2>${section.title}</h2>
    <p>${section.content}</p>
</div>`;
    }

    /**
     * Convert markdown-style links to HTML
     */
    processMarkdownLinks(text) {
        return text.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
    }

    /**
     * Replace placeholders in template
     */
    replacePlaceholders(template, data) {
        let result = template;

        // Basic replacements matching template placeholders
        const replacements = {
            'TITLE': data.meta.title,
            'SUBTITLE': data.header.sub_title,
            'TAGLINE': data.header.subtitle,
            'HERO_TITLE': data.hero.title,
            'HERO_DESCRIPTION': data.hero.description
        };

        // Replace simple placeholders
        Object.entries(replacements).forEach(([key, value]) => {
            result = result.replace(new RegExp(`{{${key}}}`, 'g'), value);
        });

        // Replace content sections
        if (data.english && data.english.sections) {
            const englishContent = this.generateContentSections(data.english.sections);
            result = result.replace('{{ENGLISH_CONTENT}}', englishContent);
        }

        if (data.french && data.french.sections) {
            const frenchContent = this.generateContentSections(data.french.sections);
            result = result.replace('{{FRENCH_CONTENT}}', frenchContent);
        } else {
            // If no French content, use placeholder
            result = result.replace('{{FRENCH_CONTENT}}', '<div class="content-section"><p>French content coming soon...</p></div>');
        }

        return result;
    }


    inlineCss(html) {
        return juice(html);
    }

    /**
     * Main build function
     */
    build(contentPath, outputPath) {
        console.log(`🚀 Building Aurora Newsletter... (Email: ${this.isEmail})`);
        
        // Load content and template
        const data = this.loadContent(contentPath);
        const template = this.loadTemplate();
        
        console.log(`📄 Loaded content: ${data.meta.edition}`);
        
        // Generate newsletter
        let newsletter = this.replacePlaceholders(template, data);

        if (this.isEmail) {
            newsletter = this.inlineCss(newsletter);
        }
        
        // Write output to root directory to maintain asset paths
        const finalOutputPath = outputPath || `${data.meta.edition}${this.isEmail ? '-email' : ''}.html`;
        fs.writeFileSync(finalOutputPath, newsletter);
        
        console.log(`✅ Newsletter built successfully: ${finalOutputPath}`);
        
        // Generate summary
        const stats = {
            'Edition': data.meta.edition,
            'Title': data.meta.title,
            'English Sections': data.english?.sections?.length || 0,
            'French Sections': data.french?.sections?.length || 0,
            'Output Size': `${Math.round(newsletter.length / 1024)}KB`,
            'Email Version': this.isEmail
        };
        
        console.log('\n📊 Build Summary:');
        Object.entries(stats).forEach(([key, value]) => {
            console.log(`   ${key}: ${value}`);
        });
    }
}

// CLI Usage
if (require.main === module) {
    const args = process.argv.slice(2);
    const isEmail = args.includes('--email');
    
    if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
        console.log(`
Aurora Newsletter Builder

Usage:
  node build.js <content-file> [output-file] [--email]
  node build.js --help

Examples:
  node build.js content/2025-06-gc-artifacts.json
  node build.js content/2025-06-gc-artifacts.json --email

Options:
  --help, -h    Show this help message
  --email       Build the email version of the newsletter
`);
        process.exit(0);
    }
    
    const contentPath = args[0];
    const outputPath = args[1] && !args[1].startsWith('--') ? args[1] : null;
    
    if (!fs.existsSync(contentPath)) {
        console.error(`❌ Content file not found: ${contentPath}`);
        process.exit(1);
    }
    
    const builder = new NewsletterBuilder(isEmail);
    builder.build(contentPath, outputPath);
}

module.exports = NewsletterBuilder;