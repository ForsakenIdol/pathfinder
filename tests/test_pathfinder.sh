#!/bin/sh

##################################################
# Minimal TAP harness for Pathfinder
# Developed by: ForsakenIdol
##################################################

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT # Cleanup before script exits
EXECUTABLE_NAME=pathfinder

########## HELPER FUNCTIONS ##########

given_test_directories() {
    mkdir -p "$TEMP_DIR/bin1" "$TEMP_DIR/bin2"
    touch "$TEMP_DIR/bin1/ls" "$TEMP_DIR/bin1/cat" 
    chmod +x "$TEMP_DIR/bin1"/*
    touch "$TEMP_DIR/bin2/foo" 
    chmod +x "$TEMP_DIR/bin2/foo"
}

########## TESTS ##########

test_basic() {
    # Given: test directories
    given_test_directories

    # When: pathfinder is called with the rest of the defaults
    # Then: pathfinder produces any output
    test -n "$(./$EXECUTABLE_NAME -p "$TEMP_DIR/bin1:$TEMP_DIR/bin2")" &&
    echo "✓ (1) Basic output OK" ||
    echo "✗ (1) Basic output FAIL"
}

test_known_path() {
    # Given
    given_test_directories

    # When
    ./$EXECUTABLE_NAME -p "$TEMP_DIR/bin1:$TEMP_DIR/bin2" > output.txt

    # Then
    EXPECTED_BIN1="^$TEMP_DIR/bin1/(cat|ls)\$"
    EXPECTED_BIN2="$TEMP_DIR/bin2/foo"
    if [ "$(wc -l < output.txt)" -eq 3 ] &&
       grep -qE "$EXPECTED_BIN1" output.txt &&
       grep -q "$EXPECTED_BIN2" output.txt; then
       echo "✓ (2) Known path OK" # Success
    else
        echo "✗ (2) Known path FAIL"
    fi
    
    # Cleanup
    rm output.txt
}

# If deduplication is toggled off, we should see a clear difference
test_no_dedupe() {
    # Given
    given_test_directories
    TEST_PATH="$TEMP_DIR/bin1:$TEMP_DIR/bin2"

    # When
    NO_DUPE=$(./$EXECUTABLE_NAME -p "$TEST_PATH:$TEST_PATH" | wc -l)
    WITH_DUPE=$(./$EXECUTABLE_NAME -p "$TEST_PATH:$TEST_PATH" -u | wc -l)

    # Then
    if [ "$WITH_DUPE" -eq $((NO_DUPE * 2)) ]; then
       echo "✓ (3) Deduplication check OK" # Success
    else
        echo "✗ (3) Deduplication check FAIL"
    fi
}

test_summary_mode() {
    # Given
    given_test_directories
    TEST_PATH="$TEMP_DIR/bin1:$TEMP_DIR/bin2"

    # When
    TMP_OUTPUT_FILE=output.txt
    ./$EXECUTABLE_NAME -p "$TEST_PATH" -s > $TMP_OUTPUT_FILE

    # Then
    if grep -q "$TEMP_DIR/bin1 2" $TMP_OUTPUT_FILE && grep -q "$TEMP_DIR/bin2 1" $TMP_OUTPUT_FILE; then
       echo "✓ (4) Summary mode OK" # Success
    else
        echo "✗ (4) Summary mode FAIL"
    fi

    rm $TMP_OUTPUT_FILE
}

test_effective_executables_only() {
    # Given
    mkdir -p "$TEMP_DIR/dup1" "$TEMP_DIR/dup2"
    touch "$TEMP_DIR/dup1/ls" && chmod +x "$TEMP_DIR/dup1/ls"
    touch "$TEMP_DIR/dup2/ls" && chmod +x "$TEMP_DIR/dup2/ls"

    # When
    TMP_OUTPUT_FILE=output.txt
    ./$EXECUTABLE_NAME -p "$TEMP_DIR/dup1:$TEMP_DIR/dup2" -e > "$TMP_OUTPUT_FILE"

    # Then
    if grep -q "$TEMP_DIR/dup1/ls" "$TMP_OUTPUT_FILE" && ! grep -q "$TEMP_DIR/dup2/ls" "$TMP_OUTPUT_FILE" ; then
        echo "✓ (5) Effective mode OK"
    else
        echo "✗ (5) Effective mode FAIL"
    fi

    # Cleanup
    rm "$TMP_OUTPUT_FILE"
}

test_empty_path() {
    # Given: Malformed PATH
    # When: Script uses malformed PATH
    # Then: Script executes with non-zero exit code
    if ./$EXECUTABLE_NAME -p "" 2>&1 | grep -q "Error"; then
        echo "✓ (6) Malformed path check OK"
    else
        echo "✗ (6) Malformed path check FAIL"
    fi
}

test_basic
test_known_path
test_no_dedupe
test_summary_mode
test_effective_executables_only
test_empty_path
