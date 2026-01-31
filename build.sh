#!/bin/bash
shopt -s extglob # Enable extended pattern matching

# BetterCainta Build Script

echo "Building BetterCainta for production..."

# DISABLE VERSION BUMPING (It causes noise during dev)
# if [ "$1" != "--no-bump" ] && [ -f "scripts/version.sh" ]; then
#     echo "Bumping version..."
#     ./scripts/version.sh patch
# fi

# Clean dist folder
rm -rf dist
mkdir -p dist

# Copy files (Excluding dist, node_modules, and git files)
echo "Copying files..."
cp -r !(dist|node_modules|.git|.vscode|build.sh|package*.json) dist/

# Minify HTML files
echo "Minifying HTML..."
find dist -name "*.html" -type f | while read file; do
    npx html-minifier-terser \
        --collapse-whitespace \
        --remove-comments \
        --remove-optional-tags \
        --remove-redundant-attributes \
        --remove-script-type-attributes \
        --remove-style-link-type-attributes \
        --minify-css true \
        --minify-js true \
        -o "$file" "$file"
done

# Minify CSS files
echo "Minifying CSS..."
find dist/assets/css -name "*.css" -type f | while read file; do
    npx cleancss -o "$file" "$file"
done

# Transpile JavaScript (ES6+ to ES5)
echo "Transpiling JavaScript with Babel..."
find dist/assets/js -name "*.js" -type f | while read file; do
    npx babel "$file" --out-file "$file"
done

# Minify JS files
echo "Minifying JavaScript..."
find dist/assets/js -name "*.js" -type f | while read file; do
    npx terser "$file" -o "$file" --compress --mangle
done

echo "Build complete!"