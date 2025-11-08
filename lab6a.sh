#!/bin/bash

mkdir -p "lab6"

cat > "lab6/poem.txt" << 'EOF'
Sun of the sleepless! Melancholy star!
Whose tearful beam glows tremulously far,
That show’st the darkness thou canst not dispel,
How like art thou to joy remember’d well!

So gleams the past, the light of other days,
Which shines, but warms not with its powerless rays;
A night-beam Sorrow watcheth to behold,
Distinct, but distant — clear, but oh, how cold!
EOF

echo "File poem.txt created"
echo "======================================"

line_number=0
found=0

while IFS= read -r line; do
    ((line_number++))
    
    if [[ -z "$line" ]]; then
        continue
    fi
    
    words=($line)
    word_count=0
    
    for word in "${words[@]}"; do
        ((word_count++))
        
        clean_word=$(echo "$word" | sed 's/[^a-zA-Z]//g')
        
        if [[ "$clean_word" == "light" ]]; then
            echo "Word 'light' found:"
            echo "Line: $line_number"
            echo "Position in line: word №$word_count"
            echo "Full line: \"$line\""
            found=1
            break 2
        fi
    done
    
done < lab6/poem.txt

if [[ $found -eq 0 ]]; then
    echo "Word 'light' not found"
fi

echo "======================================"
echo "File content:"
echo "======================================"
cat -n lab6/poem.txt
