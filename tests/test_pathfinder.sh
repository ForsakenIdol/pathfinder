#!/bin/sh

##################################################
# Minimal TAP harness for Pathfinder
# Developed by: ForsakenIdol
##################################################

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT # Cleanup before script exits

test_known_path() {
    # Given
    mkdir -p "$TEMP_DIR/bin1" "$TEMP_DIR/bin2"
    touch "$TEMP_DIR/bin1/ls" "$TEMP_DIR/bin1/cat" 
    chmod +x "$TEMP_DIR/bin1"/*
    touch "$TEMP_DIR/bin2/foo" 
    chmod +x "$TEMP_DIR/bin2/foo"

    # When
    ./"pathfinder.sh" -p "$TEMP_DIR/bin1:$TEMP_DIR/bin2" > output.txt

    # Then
    EXPECTED_BIN1="^$TEMP_DIR/bin1/(cat|ls)\$"
    EXPECTED_BIN2="$TEMP_DIR/bin2/foo"
    if [ "$(cat output.txt | wc -l)" -eq 3 ] &&
       grep -qE "$EXPECTED_BIN1" output.txt &&
       grep -q "$EXPECTED_BIN2" output.txt; then
       echo "✓ (1) Known path OK" # Success
    else
        echo "✗ (1) Known path FAIL"
    fi
    
    rm output.txt
}

test_known_path
