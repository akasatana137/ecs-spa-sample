module.exports = {
    "env": {
        "browser": true,
        "es2021": true
    },
    "extends": [
        // create react appで生成した設定を転記
        "react-app",
        "react-app/jest",
        "eslint:recommended",
        "plugin:@typescript-eslint/recommended",
        "plugin:react/recommended",
        "prettier"
    ],
    "overrides": [
        {
            "env": {
                "node": true
            },
            "files": [
                ".eslintrc.{js,cjs}"
            ],
            "parserOptions": {
                "sourceType": "script"
            }
        }
    ],
    "parser": "@typescript-eslint/parser",
    "parserOptions": {
        "ecmaVersion": "latest",
        "sourceType": "module"
    },
    "plugins": [
        "@typescript-eslint",
        "react"
    ],
    "rules": {
        "react/jsx-uses-react": "off",
        "react/react-in-jsx-scope": "off"
    }
}
