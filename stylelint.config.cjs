/** @type {import('stylelint').Config} */
module.exports = {
  rules: {
    "block-no-empty": true,
    "color-no-invalid-hex": true,
    "declaration-block-no-duplicate-properties": [
      true,
      {
        ignore: ["consecutive-duplicates-with-different-values"]
      }
    ],
    "no-empty-source": true,
    "selector-not-notation": "complex"
  }
};
