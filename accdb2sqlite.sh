#!/bin/bash

VERSION="1.0.0"
SCRIPT_NAME=$(basename "$0")

# Default values
INTERACTIVE=true
ALL_TABLES=true
SPECIFIC_TABLE=""
VERBOSE=false

show_help() {
    cat << EOF
accdb2sqlite $VERSION - Convert Microsoft Access databases to SQLite
Usage: $SCRIPT_NAME [OPTIONS] <access-file>

Options:
  -h, --help             Show this help message
  -t, --table TABLE      Convert specific table
  -a, --all-tables       Convert all tables (default)
  -o, --output FILE      Specify output SQLite file
  -l, --list-tables      List available tables and exit
  -v, --verbose          Show detailed progress
  -n, --non-interactive  Run without prompts
  --version             Show version information

Examples:
  $SCRIPT_NAME database.accdb                    # Interactive mode
  $SCRIPT_NAME -t Users database.accdb           # Convert single table
  $SCRIPT_NAME -a -n database.accdb             # Convert all tables
  $SCRIPT_NAME -l database.accdb                # List tables only

Report bugs to: https://github.com/aljayyashee/accdb2sqlite/issues
EOF
    exit 0
}

# Check dependencies
check_dependencies() {
    local missing=false
    for cmd in mdb-tables sqlite3; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "❌ Required command '$cmd' not found."
            missing=true
        fi
    done
    if [ "$missing" = true ]; then
        echo "Please install required packages:"
        echo "  Ubuntu/Debian: sudo apt install mdbtools sqlite3"
        echo "  Fedora: sudo dnf install mdbtools sqlite3"
        echo "  Arch Linux: sudo pacman -S mdbtools sqlite3"
        exit 1
    fi
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) show_help ;;
            --version) echo "$VERSION"; exit 0 ;;
            -t|--table)
                ALL_TABLES=false
                SPECIFIC_TABLE="$2"
                INTERACTIVE=false
                shift 2
                ;;
            -a|--all-tables)
                ALL_TABLES=true
                INTERACTIVE=false
                shift
                ;;
            -o|--output)
                SQLITE_FILE="$2"
                shift 2
                ;;
            -l|--list-tables)
                LIST_ONLY=true
                INTERACTIVE=false
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -n|--non-interactive)
                INTERACTIVE=false
                shift
                ;;
            *)
                ACCESS_FILE="$1"
                shift
                ;;
        esac
    done
}

# Convert a single table
convert_table() {
    local TABLE="$1"
    [ "$VERBOSE" = true ] && echo "📊 Exporting schema for table: $TABLE"
    mdb-schema "$ACCESS_FILE" sqlite | awk -v table="$TABLE" '
      BEGIN {p=0}
      $0 ~ "CREATE TABLE [`\"]?"table"[`\"]?" {p=1}
      p && /\);/ {print; exit}
      p {print}
    ' >> schema.sql

    [ "$VERBOSE" = true ] && echo "📥 Exporting data for table: $TABLE"
    mdb-export -I sqlite "$ACCESS_FILE" "$TABLE" >> data.sql
}

# Main program
main() {
    check_dependencies
    parse_arguments "$@"

    # Validate input file
    if [ -z "$ACCESS_FILE" ]; then
        if [ "$INTERACTIVE" = true ]; then
            read -e -p "Enter path to .mdb or .accdb file: " ACCESS_FILE
        else
            echo "❌ Error: No input file specified"
            show_help
        fi
    fi

    if [ ! -f "$ACCESS_FILE" ]; then
        echo "❌ File not found: $ACCESS_FILE"
        exit 1
    fi

    # Get available tables
    TABLES=$(mdb-tables -1 "$ACCESS_FILE" | grep -v '^~')

    # Handle listing tables
    if [ "$LIST_ONLY" = true ]; then
        echo "Tables in $ACCESS_FILE:"
        echo "$TABLES"
        exit 0
    fi

    # Interactive mode
    if [ "$INTERACTIVE" = true ]; then
        echo "Available tables:"
        echo "$TABLES"
        echo
        echo "Options:"
        echo "1) Convert specific table"
        echo "2) Convert all tables"
        read -p "Choose an option [1-2]: " CHOICE
        
        case $CHOICE in
            1)
                ALL_TABLES=false
                read -p "Enter table name: " SPECIFIC_TABLE
                ;;
            2)
                ALL_TABLES=true
                ;;
            *)
                echo "❌ Invalid option."
                exit 1
                ;;
        esac
    fi

    # Set output filename
    if [ -z "$SQLITE_FILE" ]; then
        SQLITE_FILE="${ACCESS_FILE%.*}.sqlite"
    fi

    # Initialize conversion
    rm -f "$SQLITE_FILE" schema.sql data.sql

    # Process tables
    if [ "$ALL_TABLES" = true ]; then
        echo "🔄 Converting all tables..."
        for TABLE in $TABLES; do
            convert_table "$TABLE"
        done
    else
        if ! echo "$TABLES" | grep -wq "$SPECIFIC_TABLE"; then
            echo "❌ Table not found: $SPECIFIC_TABLE"
            exit 1
        fi
        convert_table "$SPECIFIC_TABLE"
    fi

    # Create SQLite database
    echo "📦 Creating SQLite database: $SQLITE_FILE"
    if sqlite3 "$SQLITE_FILE" < schema.sql && sqlite3 "$SQLITE_FILE" < data.sql; then
        echo "✅ Conversion complete: $SQLITE_FILE"
        rm -f schema.sql data.sql
    else
        echo "❌ Error during conversion"
        rm -f "$SQLITE_FILE" schema.sql data.sql
        exit 1
    fi
}

# Run the program
main "$@"