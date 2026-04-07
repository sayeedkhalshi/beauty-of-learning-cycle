#!/bin/bash

INPUT="structure.md"
ROOT="knowledge_tree"

mkdir -p "$ROOT"

# Arrays to track current parent folder and counts per level
declare -a dir_stack
declare -a count_stack

dir_stack[0]="$ROOT"

# Function: count leading spaces to detect level
get_indent_level() {
    local line="$1"
    # Count number of leading spaces (2 spaces per level)
    spaces=$(echo "$line" | sed -E 's/^([ ]*).*$/\1/' | awk '{print length}')
    echo $((spaces / 2))
}

# Function: clean the item name
clean_name() {
    echo "$1" | sed -E 's/^- //' | sed 's/[\/:*?"<>|]//g' | xargs
}

while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    # Determine nesting level
    level=$(get_indent_level "$line")
    name=$(clean_name "$line")

    # Initialize counter for this level if needed
    if [ -z "${count_stack[$level]}" ]; then
        count_stack[$level]=0
    fi

    # Increment counter for current level
    count_stack[$level]=$((count_stack[$level]+1))
    index=${count_stack[$level]}

    # Trim arrays above this level
    dir_stack=("${dir_stack[@]:0:$((level+1))}")
    count_stack=("${count_stack[@]:0:$((level+1))}")

    # Determine parent folder
    parent="${dir_stack[$level]}"
    new_dir="$parent/${index}_$name"

    # Make directory
    mkdir -p "$new_dir"

    # Create file inside folder
    file="$new_dir/${index}_$name.md"
    echo "# $name" > "$file"

    # Save current directory for next level
    dir_stack[$((level+1))]="$new_dir"

done < "$INPUT"

echo "✅ Folder + file tree created in '$ROOT'"