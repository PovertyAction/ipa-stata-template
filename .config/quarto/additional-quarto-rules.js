// Additional custom markdownlint rules for Quarto Markdown
// These rules handle other Quarto-specific syntax elements beyond callout blocks

/**
 * @type {import("markdownlint").Rule}
 * Rule to validate Quarto div/span syntax
 */
module.exports.quartoDivSpanRule = {
  "names": ["quarto-div-span"],
  "description": "Validates that Quarto div and span syntax is properly formed",
  "tags": ["quarto", "divs", "spans"],
  "information": new URL("https://quarto.org/docs/authoring/markdown-basics.html"),
  "function": (params, onError) => {
    // Regular expression for div opening
    const divStartRegex = /^:::\s*\{(?:\.[\w-]+|\#[\w-]+|\s*[A-Za-z0-9_-]+=["'][^"']*["'])*\s*\}\s*$/;
    const divEndRegex = /^:::$/;

    // Regular expression for span syntax
    const spanRegex = /\[([^\]]+)\]\{(?:\.[\w-]+|\#[\w-]+|\s*[A-Za-z0-9_-]+=["'][^"']*["'])*\s*\}/g;

    let divStack = [];

    params.lines.forEach((line, lineIndex) => {
      const lineNumber = lineIndex + 1;

      // Check for div start
      if (divStartRegex.test(line)) {
        divStack.push(lineNumber);
      }

      // Check for div end
      if (divEndRegex.test(line)) {
        if (divStack.length === 0) {
          onError({
            lineNumber,
            detail: "Closing ':::' without matching opening div",
            context: line
          });
        } else {
          divStack.pop();
        }
      }

      // Check span syntax
      let match;
      while ((match = spanRegex.exec(line)) !== null) {
        // Validate span content not empty
        if (match[1].trim() === "") {
          onError({
            lineNumber,
            detail: "Span content should not be empty",
            context: match[0]
          });
        }
      }
    });

    // Check for unclosed divs
    if (divStack.length > 0) {
      divStack.forEach(startLine => {
        onError({
          lineNumber: startLine,
          detail: "Unclosed div block. Missing closing ':::'",
          context: params.lines[startLine - 1]
        });
      });
    }
  }
};

/**
 * @type {import("markdownlint").Rule}
 * Rule to validate Quarto code blocks with attributes
 */
module.exports.quartoCodeBlockRule = {
  "names": ["quarto-code-block"],
  "description": "Ensures Quarto code blocks with attributes use correct syntax",
  "tags": ["quarto", "code"],
  "information": new URL("https://quarto.org/docs/output-formats/html-code.html"),
  "function": (params, onError) => {
    // Regular expression for code block start with attributes
    const codeBlockStartRegex = /^```\{(.+?)\}\s*$/;
    // Regular expression for code block end
    const codeBlockEndRegex = /^```\s*$/;

    let inCodeBlock = false;
    let codeBlockStartLine = 0;

    params.lines.forEach((line, lineIndex) => {
      const lineNumber = lineIndex + 1;

      // Check for code block start
      const startMatch = line.match(codeBlockStartRegex);
      if (startMatch && !inCodeBlock) {
        inCodeBlock = true;
        codeBlockStartLine = lineNumber;

        // Validate cell options/attributes (lines starting with #|)
        const cellOptions = startMatch[1].split(',').map(opt => opt.trim());

        // Check language is specified
        if (!cellOptions.some(opt => /^[a-zA-Z0-9_+-]+$/.test(opt))) {
          onError({
            lineNumber,
            detail: "Code block should specify a language",
            context: line
          });
        }

        return;
      }

      // Check for code block options
      if (inCodeBlock && line.startsWith('#|')) {
        const optionLine = line.substring(2).trim();

        // Validate option syntax
        if (!/^[a-zA-Z0-9_-]+\s*:\s*.+$/.test(optionLine)) {
          onError({
            lineNumber,
            detail: "Invalid code block option syntax. Should be '#| key: value'",
            context: line
          });
        }
      }

      // Check for code block end
      if (codeBlockEndRegex.test(line) && inCodeBlock) {
        inCodeBlock = false;
        return;
      }
    });

    // Check for unclosed code block
    if (inCodeBlock) {
      onError({
        lineNumber: codeBlockStartLine,
        detail: "Unclosed code block. Missing closing '```'",
        context: params.lines[codeBlockStartLine - 1]
      });
    }
  }
};

/**
 * @type {import("markdownlint").Rule}
 * Rule to validate Quarto diagram blocks
 */
module.exports.quartoDiagramRule = {
  "names": ["quarto-diagram"],
  "description": "Validates Quarto diagram blocks (Mermaid, Graphviz)",
  "tags": ["quarto", "diagrams", "mermaid"],
  "information": new URL("https://quarto.org/docs/authoring/markdown-basics.html"),
  "function": (params, onError) => {
    // Regular expressions for diagram blocks
    const diagramStartRegex = /^```\{(mermaid|dot|graphviz)(?:\s+.*?)?\}\s*$/;
    const diagramEndRegex = /^```\s*$/;

    let inDiagramBlock = false;
    let diagramType = null;
    let diagramStartLine = 0;

    params.lines.forEach((line, lineIndex) => {
      const lineNumber = lineIndex + 1;

      // Check for diagram block start
      const startMatch = line.match(diagramStartRegex);
      if (startMatch && !inDiagramBlock) {
        inDiagramBlock = true;
        diagramType = startMatch[1];
        diagramStartLine = lineNumber;
        return;
      }

      // Check for diagram block end
      if (diagramEndRegex.test(line) && inDiagramBlock) {
        inDiagramBlock = false;
        return;
      }
    });

    // Check for unclosed diagram block
    if (inDiagramBlock) {
      onError({
        lineNumber: diagramStartLine,
        detail: `Unclosed ${diagramType} diagram block. Missing closing '```'`,
        context: params.lines[diagramStartLine - 1]
      });
    }
  }
};

/**
 * @type {import("markdownlint").Rule}
 * Rule to validate Quarto cross-references
 */
module.exports.quartoCrossRefRule = {
  "names": ["quarto-cross-reference"],
  "description": "Validates Quarto cross-references",
  "tags": ["quarto", "crossref"],
  "information": new URL("https://quarto.org/docs/authoring/cross-references.html"),
  "function": (params, onError) => {
    // Regular expression for cross-reference syntax
    const crossRefRegex = /@(fig|tbl|sec|eq|thm|lem|cor|prp|cnj|def|exm|exr|rem|lst)-([a-zA-Z0-9_-]+)/g;

    // Regular expression for label definitions
    const labelRegex = /(?:\{#(fig|tbl|sec|eq|thm|lem|cor|prp|cnj|def|exm|exr|rem|lst)-[a-zA-Z0-9_-]+)(?:\s+.*?)?\}\s*$/;

    // Collect all defined labels
    const labels = [];
    params.lines.forEach((line) => {
      const match = line.match(labelRegex);
      if (match) {
        labels.push(match[0].substring(2, match[0].indexOf('}'))); // Extract label without '#{' and '}'
      }
    });

    // Check cross-references
    params.lines.forEach((line, lineIndex) => {
      const lineNumber = lineIndex + 1;

      let match;
      while ((match = crossRefRegex.exec(line)) !== null) {
        const fullRef = match[1] + '-' + match[2];

        // Check if the referenced label exists
        if (!labels.includes(fullRef)) {
          onError({
            lineNumber,
            detail: `Cross-reference to non-existent label: "@${fullRef}"`,
            context: line.substring(Math.max(0, match.index - 5), match.index + match[0].length + 5)
          });
        }
      }
    });
  }
};

/**
 * @type {import("markdownlint").Rule}
 * Rule to handle Quarto footnotes
 */
module.exports.quartoFootnoteRule = {
  "names": ["quarto-footnote"],
  "description": "Validates Quarto footnote syntax",
  "tags": ["quarto", "footnotes"],
  "information": new URL("https://quarto.org/docs/authoring/markdown-basics.html"),
  "function": (params, onError) => {
    // Regular expressions for footnote references and definitions
    const footnoteRefRegex = /\[\^([a-zA-Z0-9_-]+)\]/g;
    const inlineFootnoteRegex = /\^\[([^\]]+)\]/g;
    const footnoteDefRegex = /^\[\^([a-zA-Z0-9_-]+)\]:/;

    // Collect all footnote definitions
    const footnoteDefs = [];
    params.lines.forEach((line) => {
      const match = line.match(footnoteDefRegex);
      if (match) {
        footnoteDefs.push(match[1]);
      }
    });

    // Check footnote references
    params.lines.forEach((line, lineIndex) => {
      const lineNumber = lineIndex + 1;

      // Check regular footnote references
      let match;
      while ((match = footnoteRefRegex.exec(line)) !== null) {
        const footnoteId = match[1];

        // Check if the referenced footnote definition exists
        if (!footnoteDefs.includes(footnoteId)) {
          onError({
            lineNumber,
            detail: `Footnote reference to non-existent definition: "[^${footnoteId}]"`,
            context: line.substring(Math.max(0, match.index - 5), match.index + match[0].length + 5)
          });
        }
      }

      // Check inline footnote syntax
      while ((match = inlineFootnoteRegex.exec(line)) !== null) {
        if (match[1].trim() === "") {
          onError({
            lineNumber,
            detail: "Inline footnote content should not be empty",
            context: match[0]
          });
        }
      }
    });
  }
};

// Mark rules as being part of a custom rule module
module.exports.names = [
  "quarto-div-span",
  "quarto-code-block",
  "quarto-diagram",
  "quarto-cross-reference",
  "quarto-footnote"
];
