#!/bin/bash

echo "Renaming theme constants throughout the project..."

# Navigate to lib directory
cd flutter_app/lib

# Rename constants in all Dart files
find . -name "*.dart" -type f -exec sed -i '' \
    -e 's/AppTheme\.warmBrown/AppTheme.charcoal/g' \
    -e 's/AppTheme\.lightBrown/AppTheme.lightGray/g' \
    -e 's/AppTheme\.darkBrown/AppTheme.burgundy/g' \
    -e 's/AppTheme\.cream/AppTheme.offWhite/g' \
    -e 's/AppTheme\.gold/AppTheme.mediumGray/g' \
    -e 's/AppTheme\.accent/AppTheme.accent/g' \
    -e 's/AppTheme\.lightGray/AppTheme.gray/g' \
    {} \;

echo "Constant renaming complete!"
