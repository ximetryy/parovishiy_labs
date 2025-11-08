input_matrix() {
    local matrix_name=$1
    echo "Enter matrix $matrix_name (3x3):"
    echo "Format: a11 a12 a13"
    
    for i in {0..2}; do
        while true; do
            read -p "Line $((i+1)): " -a row
            if [ ${#row[@]} -eq 3 ]; then
                valid=true
                for element in "${row[@]}"; do
                    if ! [[ $element =~ ^-?[0-9]+$ ]]; then
                        echo "Error: Enter integer!"
                        valid=false
                        break
                    fi
                done
                if $valid; then
                    eval "$matrix_name$i=(\"\${row[@]}\")"
                    break
                fi
            else
                echo "Error: Enter 3 number separated by a space!"
            fi
        done
    done
}

print_matrix() {
    local matrix_name=$1
    local title=$2
    
    echo "$title"
    for i in {0..2}; do
        eval "row=(\"\${$matrix_name$i[@]}\")"
        printf "| %6d %6d %6d |\n" "${row[0]}" "${row[1]}" "${row[2]}"
    done
    echo
}

matrix_addition() {
    for i in {0..2}; do
        eval "rowA=(\"\${A$i[@]}\")"
        eval "rowB=(\"\${B$i[@]}\")"
        result=()
        for j in {0..2}; do
            result[j]=$((rowA[j] + rowB[j]))
        done
        eval "C$i=(\"\${result[@]}\")"
    done
}

matrix_subtraction() {
    for i in {0..2}; do
        eval "rowA=(\"\${A$i[@]}\")"
        eval "rowB=(\"\${B$i[@]}\")"
        result=()
        for j in {0..2}; do
            result[j]=$((rowA[j] - rowB[j]))
        done
        eval "C$i=(\"\${result[@]}\")"
    done
}

while true; do
    echo "================================="
    echo "     Matrix Calculator 3x3"
    echo "================================="
    echo "1. Addition (A + B)"
    echo "2. Substraction (A - B)"
    echo "3. Show entered matrix"
    echo "4. Exit"
    echo "================================="
    
    read -p "Select operation (1-4): " choice
    
    case $choice in
        1|2)
            echo
            input_matrix "A"
            echo
            input_matrix "B"
            echo
            
            if [ $choice -eq 1 ]; then
                matrix_addition
                operation="ADDITION"
                symbol="A + B"
            else
                matrix_subtraction
                operation="SUBSTRACTION"
                symbol="A - B"
            fi
            
            echo "================================="
            echo "         $operation RESULT"
            echo "================================="
            print_matrix "A" "MATRIX A:"
            print_matrix "B" "MATRIX B:"
            print_matrix "C" "Result $symbol:"
            ;;
        
        3)
            if [ -n "${A0[0]}" ]; then
                echo
                print_matrix "A" "Matrix A:"
                print_matrix "B" "Matrix B:"
            else
                echo "Need enter matrix"
            fi
            ;;
        
        4)
            echo "Quiting..."
            exit 0
            ;;
        
        *)
            echo "Wrong choice."
            ;;
    esac
    
    echo
    read -p "Press ENTER to continue..."
    clear
done
