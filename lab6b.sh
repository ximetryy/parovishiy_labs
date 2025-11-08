#!/bin/bash

dir_name="lab6"
mkdir -p "$dir_name"
cd "$dir_name" || exit 1

echo "Directory created: $dir_name"
echo "Creating 5 files..."

cat > file1.txt << 'EOF'
Programming is the art of solving problems using a computer.
Software development requires attention to detail and logical thinking.
EOF

cat > file2.txt << 'EOF'
Artificial intelligence is changing the world around us.
Machine learning allows computers to learn from data.
 TA256SHA
EOF

cat > file3.txt << 'EOF'
Cybersecurity is an important field in the modern digital world.
Data protection requires constant updating of knowledge and skills.
EOF

cat > file4.txt << 'EOF'
Web development includes frontend and backend technologies.
JavaScript and Python are popular programming languages.
 TA256SHA
EOF

cat > file5.txt << 'EOF'
Databases store and organize information.
SQL is a language for working with relational databases.
EOF

echo "Files created successfully!"
echo "======================================"

echo "Searching for files containing 'TA256SHA'..."
echo "======================================"

found_files=()

for file in *.txt; do
    if grep -q "TA256SHA" "$file"; then
        found_files+=("$file")
        echo "FOUND in file: $file"
        echo "File contents:"
        echo "-----------------"
        cat "$file"
        echo "-----------------"
        echo
    fi
done

echo "======================================"
echo "SUMMARY:"
echo "Total files: $(ls *.txt | wc -l)"
echo "Files with 'TA256SHA': ${#found_files[@]}"
echo "Filenames with 'TA256SHA': ${found_files[*]}"