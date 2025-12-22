// Custom markdownlint rules for Quarto Markdown
// These rules support Quarto's special syntax elements like callout blocks

/**
 * @type {import("markdownlint").Rule}
 * Rule to allow Quarto callout blocks syntax
 */
module.exports.quartoCalloutRule = {
  "names": ["quarto-callout-blocks"],
  "description": "Validates that Quarto callout blocks follow proper syntax",
  "tags": ["quarto", "callouts"],
  "information": new URL("https://quarto.org/docs/authoring/callouts.html"),
  "function": (params, onError) => {
    // Regular expression to match Quarto callout block start
    const calloutStartRegex = /^:::\s*\{\.callout-(note|tip|warning|caution|important)(?:(?:\s+|\s*,\s*).*?)?\}\s*$/;
    // Regular expression to match Quarto callout block end
    const calloutEndRegex = /^:::$/;
    
    let inCalloutBlock = false;
    let calloutStartLine = 0;
    let calloutType = null;
    
    params.lines.forEach((line, lineIndex) => {
      const lineNumber = lineIndex + 1;
      
      // Check for callout start
      const startMatch = line.match(calloutStartRegex);
      if (startMatch && !inCalloutBlock) {
        inCalloutBlock = true;
        calloutStartLine = lineNumber;
        calloutType = startMatch[1];
        return;
      }
      
      // Check for callout end
      if (calloutEndRegex.test(line) && inCalloutBlock) {
        inCalloutBlock = false;
        return;
      }
      
      // Invalid closing ::: without opening
      if (calloutEndRegex.test(line) && !inCalloutBlock) {
        onError({
          lineNumber,
          detail: "Closing ':::' without matching opening callout block",
          context: line
        });
        return;
      }
    });
    
    // Detect unclosed callout block
    if (inCalloutBlock) {
      onError({
        lineNumber: calloutStartLine,
        detail: `Unclosed callout block of type '${calloutType}'. Missing closing ':::'`,
        context: params.lines[calloutStartLine - 1]
      });
    }
  }
};

/**
 * @type {import("markdownlint").Rule}
 * Rule to validate Quarto callout block titles
 */
module.exports.quartoCalloutTitleRule = {
  "names": ["quarto-callout-title"],
  "description": "Ensures Quarto callout blocks have properly formatted titles",
  "tags": ["quarto", "callouts", "headings"],
  "information": new URL("https://quarto.org/docs/authoring/callouts.html"),
  "function": (params, onError) => {
    const calloutStartRegex = /^:::\s*\{\.callout-(note|tip|warning|caution|important)(?:(?:\s+|\s*,\s*).*?)?\}\s*$/;
    const calloutEndRegex = /^:::$/;
    const titleAttributeRegex = /title="([^"]+)"/;
    const headerRegex = /^#{1,6}\s+(.+)$/;
    
    let inCalloutBlock = false;
    let calloutStartLine = 0;
    let hasTitleAttribute = false;
    let hasHeadingTitle = false;
    
    params.lines.forEach((line, lineIndex) => {
      const lineNumber = lineIndex + 1;
      
      // Check for callout start
      const startMatch = line.match(calloutStartRegex);
      if (startMatch && !inCalloutBlock) {
        inCalloutBlock = true;
        calloutStartLine = lineNumber;
        hasTitleAttribute = titleAttributeRegex.test(line);
        hasHeadingTitle = false;
        return;
      }
      
      // Check for heading as title in the next line after callout start
      if (inCalloutBlock && lineNumber === calloutStartLine + 1 && headerRegex.test(line)) {
        hasHeadingTitle = true;
      }
      
      // Check for callout end
      if (calloutEndRegex.test(line) && inCalloutBlock) {
        // If neither title method is used, report an error
        if (!hasTitleAttribute && !hasHeadingTitle) {
          onError({
            lineNumber: calloutStartLine,
            detail: "Callout block should have either a title attribute or a heading as the first line",
            context: params.lines[calloutStartLine - 1]
          });
        }
        
        inCalloutBlock = false;
        return;
      }
    });
  }
};

/**
 * @type {import("markdownlint").Rule}
 * Rule to validate Quarto collapsible callout blocks
 */
module.exports.quartoCollapsibleCalloutRule = {
  "names": ["quarto-collapsible-callout"],
  "description": "Checks that collapsible Quarto callouts have proper syntax",
  "tags": ["quarto", "callouts", "collapse"],
  "information": new URL("https://quarto.org/docs/authoring/callouts.html"),
  "function": (params, onError) => {
    const collapsibleCalloutRegex = /^:::\s*\{\.callout-(?:note|tip|warning|caution|important)(?:.*?)\s+collapse="(true|false)"(?:.*?)?\}\s*$/;
    
    params.lines.forEach((line, lineIndex) => {
      const lineNumber = lineIndex + 1;
      
      // Check for collapsible callout with invalid value
      const match = line.match(/^:::\s*\{\.callout-(?:note|tip|warning|caution|important)(?:.*?)\s+collapse="([^"]*)"(?:.*?)?\}\s*$/);
      if (match && !['true', 'false'].includes(match[1])) {
        onError({
          lineNumber,
          detail: `Invalid value for 'collapse' attribute: "${match[1]}". Must be either "true" or "false"`,
          context: line
        });
      }
    });
  }
};

/**
 * @type {import("markdownlint").Rule}
 * Rule to validate Quarto callout appearance attribute
 */
module.exports.quartoCalloutAppearanceRule = {
  "names": ["quarto-callout-appearance"],
  "description": "Checks that Quarto callout appearance attribute has valid values",
  "tags": ["quarto", "callouts", "appearance"],
  "information": new URL("https://quarto.org/docs/authoring/callouts.html"),
  "function": (params, onError) => {
    const appearanceRegex = /^:::\s*\{\.callout-(?:note|tip|warning|caution|important)(?:.*?)\s+appearance="([^"]*)"(?:.*?)?\}\s*$/;
    const validAppearances = ['default', 'simple', 'minimal'];
    
    params.lines.forEach((line, lineIndex) => {
      const lineNumber = lineIndex + 1;
      
      // Check for appearance attribute with invalid value
      const match = line.match(appearanceRegex);
      if (match && !validAppearances.includes(match[1])) {
        onError({
          lineNumber,
          detail: `Invalid value for 'appearance' attribute: "${match[1]}". Must be one of: ${validAppearances.join(', ')}`,
          context: line
        });
      }
    });
  }
};

/**
 * @type {import("markdownlint").Rule}
 * Rule to allow Quarto callout cross-references
 */
module.exports.quartoCalloutCrossRefRule = {
  "names": ["quarto-callout-crossref"],
  "description": "Validates that Quarto callout cross-references use correct syntax",
  "tags": ["quarto", "callouts", "crossref"],
  "information": new URL("https://quarto.org/docs/authoring/callouts.html"),
  "function": (params, onError) => {
    // Regular expression to match Quarto callout with ID
    const calloutWithIdRegex = /^:::\s*\{(?:#([a-zA-Z0-9_-]+)(?:-[a-zA-Z0-9_-]+)?)(?:\.callout-(?:note|tip|warning|caution|important)(?:.*?)?)?\}\s*$/;
    // Regular expression to match cross-reference to callout
    const crossRefRegex = /@([a-zA-Z0-9_-]+(?:-[a-zA-Z0-9_-]+)?)/g;
    
    // Collect all callout IDs
    const calloutIds = [];
    params.lines.forEach((line) => {
      const match = line.match(calloutWithIdRegex);
      if (match && match[1]) {
        calloutIds.push(match[1]);
      }
    });
    
    // Check cross-references
    params.lines.forEach((line, lineIndex) => {
      const lineNumber = lineIndex + 1;
      
      let match;
      while ((match = crossRefRegex.exec(line)) !== null) {
        const refId = match[1];
        // Skip if this is not a callout reference (e.g., figure, table, etc.)
        if (!refId.startsWith('note-') && 
            !refId.startsWith('tip-') && 
            !refId.startsWith('warning-') && 
            !refId.startsWith('caution-') && 
            !refId.startsWith('important-')) {
          continue;
        }
        
        // Strip the prefix to get the callout ID
        const calloutIdParts = refId.split('-');
        calloutIdParts.shift(); // Remove the prefix (note, tip, etc.)
        const calloutId = calloutIdParts.join('-');
        
        // Check if the referenced ID exists
        if (!calloutIds.includes(calloutId)) {
          onError({
            lineNumber,
            detail: `Cross-reference to non-existent callout ID: "${refId}"`,
            context: line.substring(Math.max(0, match.index - 5), match.index + match[0].length + 5)
          });
        }
      }
    });
  }
};

// Mark rules as being part of a custom rule module
module.exports.names = [
  "quarto-callout-blocks",
  "quarto-callout-title",
  "quarto-collapsible-callout",
  "quarto-callout-appearance",
  "quarto-callout-crossref"
];
