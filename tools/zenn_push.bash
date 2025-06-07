#!/bin/bash

add_article() {
  if [ $# -ne 2 ]; then
    echo "Usage: $0 <html_file> <html_to_insert>"
    exit 1
  fi

  html_file="$1"
  html_to_insert="$2"

  # macOSのsedで変数を使って行追加。安全策で一時ファイル利用
  tmpfile=$(mktemp)
  sed "/<ul class=\"articles_list\">/a\\
${html_to_insert}
" "$html_file" > "$tmpfile" && mv "$tmpfile" "$html_file"
}

SOURCE_DIR="$HOME/Documents/zeen/zenn_content/articles"
DESTINATION_DIR="$HOME/Documents/zeen/zenn_content/docs"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory '$SOURCE_DIR' does not exist."
  exit 1
fi

mkdir -p "$DESTINATION_DIR"

find "$SOURCE_DIR" -type f -print0 | while IFS= read -r -d $'\0' file; do
  if grep -qE '^\s*published:\s*true\s*$' "$file"; then
    cp "$file" "$DESTINATION_DIR"
    title=$(grep '^title: ' "$file" | sed -n 's/^title: *"\(.*\)"/\1/p' | tr -d '\r\n')
    safe_title=$(echo "$title" | sed 's/[^a-zA-Z0-9_-]//g')
    add_article "$DESTINATION_DIR/index.html" "<li><a href=\"/docs/${safe_title}.html\">${title}</a></li>"
    # pandoc "$file" -o "$DESTINATION_DIR/${safe_title}.html"
    pandoc -s --template=$HOME/Documents/zeen/zenn_content/docs/mytemplate.html "$file" -o "$DESTINATION_DIR/${safe_title}.html"

    echo "Copied: $file to $DESTINATION_DIR"
  fi
done

rm $DESTINATION_DIR/*.md

for file in "$DESTINATION_DIR"/*html; do
    filename=$(basename "$file")
    
    if [ "$filename" = "header.html" ]; then
      continue
    fi
    
    if [ "$filename" = "index.html" ]; then
      continue
    fi

    line="<h1>$title</h1>"
    sed -i '' "1i\\
    $line
    " $file
    
    line2='<div id="header"></div>'
    sed -i '' "1i\\
    $line2
    " $file
    
    echo "<script>
      fetch("header.html")
        .then((response) => response.text())
        .then((data) => {
          document.getElementById("header").innerHTML = data;
        });
    </script>" >> $file

    prettier --write "$file"
done


echo "Script finished."
