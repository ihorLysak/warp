#!/bin/bash

add_gate() {
    local gate_name="$1"
    echo "$gate_name: $(pwd)" >> /Users/ihorlysak/warp/gates.txt
}

get_gate_path() {
    local gate_name="$1"
    local file_path="/Users/ihorlysak/warp/gates.txt"
    
    if [ ! -f "$file_path" ]; then
        echo "The gate file does not exist."
        return 1
    fi

    local line=$(grep "^$gate_name:" $file_path)
    if [ -z "$line" ]; then
        echo "Gate name '$gate_name' not found."
        return 1
    else
        local gate_path=$(echo $line | cut -d ':' -f2 | xargs)
        echo $gate_path
    fi
}

remove_gate() {
    local gate_name="$1"
    local file_path="/Users/ihorlysak/warp/gates.txt"

    if [ ! -f "$file_path" ]; then
        echo "The gate file does not exist."
        return 1
    fi

    grep -v "^$gate_name:" "$file_path" > "$file_path.tmp" && mv "$file_path.tmp" "$file_path"

    if [ $? -eq 0 ]; then
        echo "Gate '$gate_name' removed successfully."
    else
        echo "Failed to remove gate '$gate_name'."
        return 1
    fi
}

list_gates() {
    local file_path="/Users/ihorlysak/warp/gates.txt"
    if [ ! -f "$file_path" ]; then
        echo "No gates file found. No gates to display."
        return 1
    fi

    while IFS=': ' read -r gate_name gate_path; do
        echo "Gate name: $gate_name, Path: $gate_path"
    done < "$file_path"
}

case "$1" in
    add)
        if [ -n "$2" ]; then
            add_gate "$2"
        else
            echo "Usage: warp add <gate_name>"
        fi
        ;;
    remove)
        if [ -n "$2" ]; then
            remove_gate "$2"
        else
            echo "Usage: warp remove <gate_name>"
        fi
        ;;
    list)
        list_gates
        ;;
    blink)
        if [ -n "$2" ]; then
            gate_path=$(get_gate_path "$2")
            if [ -n "$gate_path" ]; then 
                code -r "$gate_path" || {
                    echo "Failed to open editor at '$gate_path'"
                }
            else
                echo "No valid path found for gate '$2'."
            fi
        else
            echo "Usage: warp blink <gate_name>"
        fi
        ;;
    *)
        if [ -n "$1" ]; then
            gate_path=$(get_gate_path "$1")
            if [ -n "$gate_path" ]; then 
                cd "$gate_path" || {
                    echo "Failed to change directory to '$gate_path'"
                }
            else
                echo "No valid path found for gate '$1'."
            fi
        else
            echo "Usage: warp [ add <gate_name> | remove <gate_name> | blink <gate_namew> | list | <gate_name> ]"
        fi  
        ;;
esac 
        
