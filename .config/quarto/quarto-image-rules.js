// Custom markdownlint rules for Quarto image validation
// These rules enforce accessibility requirements for images in Quarto documents

/**
 * @type {import("markdownlint").Rule}
 * Rule to validate Quarto image alt text requirements
 */
module.exports.quartoImageAltTextRule = {
  "names": ["quarto-image-alt-text"],
  "description": "Ensures images in Quarto documents have alternative text",
  "tags": ["quarto", "images", "accessibility"],
  "information": new URL("https://quarto.org/docs/authoring/markdown-basics.html#figures"),
  "function": (params, onError) => {
    // Regular expression for markdown image syntax
    const markdownImageRegex = /!\[(.*?)\]\((.*?)\)/g;
    
    // Regular expression for Quarto figure syntax with attributes
    const quartoFigureRegex = /!\[(.*?)\]\((.*?)\)(\{.*?\})?/g;
    
    // Regular expression for HTML img tags
    const htmlImgRegex = /<img\s+[^>]*?(?:src|alt)=[^>]*?>/g;
    
    params.lines.forEach((line, lineIndex) => {
      const lineNumber = lineIndex + 1;
      
      // Check standard markdown images
      let match;
      while ((match = markdownImageRegex.exec(line)) !== null) {
        const altText = match[1].trim();
        if (!altText) {
          onError({
            lineNumber,
            detail: "Image missing alt text. Add descriptive alternative text for accessibility.",
            context: match[0]
          });
        } else if (altText === "image" || altText === "figure" || altText === "chart" || altText === "diagram" || altText === "picture" || altText === "photo") {
          onError({
            lineNumber,
            detail: `Generic alt text "${altText}" detected. Use more descriptive alternative text.`,
            context: match[0]
          });
        }
      }
      
      // Reset regex lastIndex
      markdownImageRegex.lastIndex = 0;
      
      // Check Quarto figure syntax with attributes
      while ((match = quartoFigureRegex.exec(line)) !== null) {
        const altText = match[1].trim();
        const attributes = match[3] || "";
        
        // Check if alt text is provided in attributes (using fig-alt)
        const figAltMatch = attributes.match(/fig-alt="([^"]*)"/);
        const hasAltInAttributes = figAltMatch && figAltMatch[1].trim().length > 0;
        
        if (!altText && !hasAltInAttributes) {
          onError({
            lineNumber,
            detail: "Image missing alt text. Add alt text in brackets or use fig-alt attribute.",
            context: match[0]
          });
        }
      }
      
      // Reset regex lastIndex
      quartoFigureRegex.lastIndex = 0;
      
      // Check HTML img tags
      while ((match = htmlImgRegex.exec(line)) !== null) {
        const imgTag = match[0];
        
        // Check if alt attribute exists and has content
        const altMatch = imgTag.match(/alt=["']([^"']*)["']/);
        if (!altMatch) {
          onError({
            lineNumber,
            detail: "HTML img tag missing alt attribute. Add alt=\"descriptive text\" for accessibility.",
            context: imgTag
          });
        } else if (!altMatch[1].trim()) {
          onError({
            lineNumber,
            detail: "HTML img tag has empty alt attribute. Add descriptive alternative text.",
            context: imgTag
          });
        } else if (["image", "figure", "chart", "diagram", "picture", "photo"].includes(altMatch[1].trim().toLowerCase())) {
          onError({
            lineNumber,
            detail: `Generic alt text "${altMatch[1]}" detected. Use more descriptive alternative text.`,
            context: imgTag
          });
        }
      }
    });
  }
};

// Export rule names
module.exports.names = [
  "quarto-image-alt-text"
];