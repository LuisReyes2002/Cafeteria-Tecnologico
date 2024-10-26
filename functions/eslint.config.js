// eslint.config.js
module.exports = [
    {
      files: ["*.js"],
      parserOptions: {
        ecmaVersion: 2020,
        sourceType: "module",
      },
      env: {
        es6: true,
        node: true,
      },
      rules: {
        quotes: ["error", "double"], // Usa comillas dobles
        "object-curly-spacing": ["error", "never"], // Sin espacios en llaves
        indent: ["error", 2], // Indentación de 2 espacios
        "max-len": ["error", { code: 80 }], // Longitud máxima de línea
      },
    },
  ];
  
  