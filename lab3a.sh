#!/bin/bash

show_menu() {
    echo "================================="
    echo "          CALCULATOR"
    echo "================================="
    echo "1. Addition (+)"
    echo "2. Substraction (-)"
    echo "3. Meltyply (*)"
    echo "4. Dividion (/)"
    echo "5. Exponentiation (^)"
    echo "6. Exit"
    echo "================================="
}

input_numbers() {
    read -p "Enter first number: " num1
    read -p "Enter second number: " num2
}

validate_numbers() {
    if ! [[ $num1 =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || ! [[ $num2 =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: enter correct numbers"
        return 1
    fi
    return 0
}

while true; do
    show_menu
    read -p "Select operation (1-6): " choice
    
    case $choice in
        1)
            input_numbers
            if validate_numbers; then
                result=$(echo "$num1 + $num2" | bc -l)
                echo "Result: $num1 + $num2 = $result"
            fi
            ;;
        2)
            input_numbers
            if validate_numbers; then
                result=$(echo "$num1 - $num2" | bc -l)
                echo "Result: $num1 - $num2 = $result"
            fi
            ;;
        3)
            input_numbers
            if validate_numbers; then
                result=$(echo "$num1 * $num2" | bc -l)
                echo "Result: $num1 * $num2 = $result"
            fi
            ;;
        4)
            input_numbers
            if validate_numbers; then
                if (( $(echo "$num2 == 0" | bc -l) )); then
                    echo "Error: division on zero!"
                else
                    result=$(echo "scale=4; $num1 / $num2" | bc -l)
                    echo "Result: $num1 / $num2 = $result"
                fi
            fi
            ;;
        5)
            input_numbers
            if validate_numbers; then
                
                result=$(echo "scale=4; $num1 ^ $num2" | bc -l 2>/dev/null)
                if [ $? -ne 0 ]; then
                    echo "Error!"
                else
                    echo "Result: $num1 ^ $num2 = $result"
                fi
            fi
            ;;
        6)
            echo "Quiting"
            exit 0
            ;;
        *)
            echo "Wrong choice."
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
    clear
done
