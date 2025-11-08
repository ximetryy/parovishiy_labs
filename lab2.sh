#!/bin/bash

dir_name="lab2"
mkdir -p "$dir_name"
cd "$dir_name" || exit 1

echo "Create directory: $dir_name"
echo "Create 10 files..."

for i in {1..10}; do
    touch "file$i.txt"
done

echo "Writing 3 files..."
echo "File 1 content" > file1.txt
echo "File 5 content" > file5.txt
echo "file 9 content" > file9.txt

echo "Current files state"
ls -la

echo -e "\nCheck empty files..."
empty_files=()

for file in file*.txt; do
    if [ ! -s "$file" ]; then
        empty_files+=("$file")
    fi
done

echo "Empty files to write: ${empty_files[*]}"

echo -e "\nWriting empty files..."
for file in "${empty_files[@]}"; do
    echo "Writing file: $file"
    echo "Auto filled file $(date)" > "$file"
    echo "Random value: $RANDOM" >> "$file"
    echo "File: $file" >> "$file"
done

echo -e "\nFinal files state:"
ls -la

echo -e "\nAll files contet:"
for file in file*.txt; do
    echo "=== $file ==="
    cat "$file"
    echo -e "\n"
done
