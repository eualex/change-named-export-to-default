#!/bin/bash

DIR="./src"

is_pascal_case() {
  local name="$1"
  [[ "$name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]
}

grep -r "const [A-Z][a-zA-Z0-9]* = (" "$DIR" --include \*.tsx | while read -r line; do
  FILE=$(echo "$line" | cut -d: -f1)
  COMPONENT_NAME=$(echo "$line" | perl -nle 'print $1 if /const ([A-Z][a-zA-Z0-9]*) =/')

  if is_pascal_case "$COMPONENT_NAME"; then
    if grep -q "export { $COMPONENT_NAME };" "$FILE"; then
      echo "Modifying export in $FILE"
      sed -i "" "s/export { $COMPONENT_NAME };/export default $COMPONENT_NAME;/g" "$FILE"
      grep -rl "import { $COMPONENT_NAME } from" "$DIR" --include \*.tsx | while read -r IMPORT_FILE; do
        echo "Modifying import in $IMPORT_FILE"
        sed -i "" "s/import { $COMPONENT_NAME } from/import $COMPONENT_NAME from/g" "$IMPORT_FILE"
      done
    fi
  fi
done

echo "Process completed."
