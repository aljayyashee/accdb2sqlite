#!/bin/bash

# Installation configuration
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="accdb2sqlite"
VERSION="1.0.0"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/accdb2sqlite.sh"
MAN_DIR="/usr/local/share/man/man1"
COMPLETION_DIR="/etc/bash_completion.d"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print colored messages
print_msg() {
    echo -e "${2}${1}${NC}"
}

# Function to check root privileges
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        print_msg "❌ Please run as root or with sudo" "$RED"
        exit 1
    fi
}

# Install dependencies based on package manager
install_dependencies() {
    local success=true
    local pkg_manager=""

    # Detect package manager
    if command -v apt-get &> /dev/null; then
        pkg_manager="apt"
        print_msg "📥 Installing dependencies via apt..." "$BLUE"
        apt-get update || success=false
        apt-get install -y mdbtools sqlite3 man gzip || success=false
    elif command -v dnf &> /dev/null; then
        pkg_manager="dnf"
        print_msg "📥 Installing dependencies via dnf..." "$BLUE"
        dnf install -y mdbtools sqlite3 man-db || success=false
    elif command -v pacman &> /dev/null; then
        pkg_manager="pacman"
        print_msg "📥 Installing dependencies via pacman..." "$BLUE"
        pacman -Sy --noconfirm mdbtools sqlite3 man-db || success=false
    elif command -v xbps-install &> /dev/null; then
        pkg_manager="xbps"
        print_msg "📥 Installing dependencies via xbps..." "$BLUE"
        xbps-install -Sy mdb-tools sqlite man-pages || success=false
    else
        print_msg "❌ Unsupported package manager" "$RED"
        print_msg "Please install manually: mdbtools sqlite3" "$YELLOW"
        exit 1
    fi

    if [ "$success" = false ]; then
        print_msg "❌ Failed to install dependencies" "$RED"
        exit 1
    fi
}

# Verify dependencies
verify_dependencies() {
    local missing=false
    for cmd in mdb-tables sqlite3; do
        if ! command -v "$cmd" &> /dev/null; then
            print_msg "❌ Required command '$cmd' not found" "$RED"
            missing=true
        fi
    done
    return $([ "$missing" = true ])
}

# Create man page
create_man_page() {
    mkdir -p "$MAN_DIR"
    cat > "$MAN_DIR/$SCRIPT_NAME.1" << 'EOF'
.TH ACCDB2SQLITE 1 "April 2025" "Version 1.0.0" "User Commands"
.SH NAME
accdb2sqlite \- convert Microsoft Access databases to SQLite
.SH SYNOPSIS
.B accdb2sqlite
[\fIOPTIONS\fR] \fIaccess-file\fR
.SH DESCRIPTION
.B accdb2sqlite
converts Microsoft Access databases (.mdb/.accdb) to SQLite format.
.SH OPTIONS
.TP
.BR \-h ", " \-\-help
Show help message
.TP
.BR \-t ", " \-\-table " " \fITABLE\fR
Convert specific table
.TP
.BR \-a ", " \-\-all\-tables
Convert all tables (default)
.TP
.BR \-o ", " \-\-output " " \fIFILE\fR
Specify output SQLite file
.TP
.BR \-l ", " \-\-list\-tables
List available tables and exit
.TP
.BR \-v ", " \-\-verbose
Show detailed progress
.TP
.BR \-n ", " \-\-non\-interactive
Run without prompts
.SH EXAMPLES
.TP
Convert all tables:
.B accdb2sqlite
database.accdb
.TP
Convert specific table:
.B accdb2sqlite
\-t Users database.accdb
EOF
    gzip -f "$MAN_DIR/$SCRIPT_NAME.1"
}

# Create bash completion
create_completion() {
    mkdir -p "$COMPLETION_DIR"
    cat > "$COMPLETION_DIR/$SCRIPT_NAME" << 'EOF'
_accdb2sqlite() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-h --help -t --table -a --all-tables -o --output -l --list-tables -v --verbose -n --non-interactive --version"

    case "$prev" in
        -t|--table|-o|--output)
            COMPREPLY=()
            return 0
            ;;
        *)
            if [[ ${cur} == -* ]]; then
                COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            else
                COMPREPLY=( $(compgen -f -- ${cur}) )
            fi
            return 0
            ;;
    esac
}
complete -F _accdb2sqlite accdb2sqlite
EOF
}

# Create uninstall script
create_uninstall() {
    cat > "$INSTALL_DIR/uninstall-$SCRIPT_NAME" << EOF
#!/bin/bash
if [ "\$EUID" -ne 0 ]; then 
    echo "❌ Please run as root or with sudo"
    exit 1
fi
rm -f "$INSTALL_DIR/$SCRIPT_NAME"
rm -f "$COMPLETION_DIR/$SCRIPT_NAME"
rm -f "$MAN_DIR/$SCRIPT_NAME.1.gz"
rm -f "\$0"
echo "✅ $SCRIPT_NAME uninstalled successfully"
EOF
    chmod +x "$INSTALL_DIR/uninstall-$SCRIPT_NAME"
}

# Main installation
main() {
    check_root
    
    print_msg "📦 accdb2sqlite installer v${VERSION}" "$BLUE"
    print_msg "=================================="

    # Check and install dependencies
    print_msg "🔍 Checking dependencies..." "$BLUE"
    if ! verify_dependencies; then
        install_dependencies
    fi

    # Install main script
    print_msg "📋 Installing accdb2sqlite..." "$BLUE"
    if ! cp "$SCRIPT_PATH" "$INSTALL_DIR/$SCRIPT_NAME"; then
        print_msg "❌ Failed to install main script" "$RED"
        exit 1
    fi
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

    # Install man page
    print_msg "📚 Installing man page..." "$BLUE"
    create_man_page
    print_msg "✅ Man page installed" "$GREEN"

    # Install bash completion
    print_msg "🔧 Installing bash completion..." "$BLUE"
    create_completion
    print_msg "✅ Bash completion installed" "$GREEN"

    # Create uninstall script
    create_uninstall
    print_msg "✅ Installation successful!" "$GREEN"

    # Final instructions
    print_msg "\n📝 Usage:" "$BLUE"
    print_msg "  • Run: accdb2sqlite --help" "$BLUE"
    print_msg "  • Man page: man accdb2sqlite" "$BLUE"
    print_msg "  • Uninstall: sudo uninstall-accdb2sqlite" "$BLUE"
    print_msg "\n💡 Note: Restart your terminal for bash completion to take effect" "$YELLOW"
}

main