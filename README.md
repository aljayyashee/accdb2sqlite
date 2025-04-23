# accdb2sqlite 🗃️

> Convert Microsoft Access databases (.mdb/.accdb) to SQLite

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)

## 🌟 Features

- Convert Access databases (.mdb/.accdb) to SQLite
- Interactive and command-line modes
- Single table or full database conversion
- Preserves table schemas and data
- Progress tracking and verbose output options
- System-wide installation support

## 📋 Prerequisites

You need `mdbtools` and `sqlite3` installed on your system:

```bash
# Ubuntu/Debian
sudo apt install mdbtools sqlite3

# Fedora
sudo dnf install mdbtools sqlite3

# Arch Linux
sudo pacman -S mdbtools sqlite3

# Void Linux
sudo xbps-install -S mdb-tools sqlite
```

## 🚀 Installation

1. Clone the repository:
```bash
git clone https://github.com/aljayyashee/accdb2sqlite.git
cd accdb2sqlite
```

2. Make scripts executable:
```bash
chmod +x install.sh accdb2sqlite.sh
```

3. Install system-wide:
```bash
sudo ./install.sh
```

## 📖 Usage

### Basic Usage:
```bash
accdb2sqlite database.accdb
```

### Command-line Options:
```
-h, --help             Show help message
-t, --table TABLE      Convert specific table
-a, --all-tables       Convert all tables (default)
-o, --output FILE      Specify output SQLite file
-l, --list-tables      List available tables and exit
-v, --verbose          Show detailed progress
-n, --non-interactive  Run without prompts
--version             Show version information
```

### Examples:

1. Convert specific table:
```bash
accdb2sqlite -t Users database.accdb
```

2. Convert all tables with custom output:
```bash
accdb2sqlite -a -o output.db database.accdb
```

3. List available tables:
```bash
accdb2sqlite -l database.accdb
```

4. Verbose conversion:
```bash
accdb2sqlite -v database.accdb
```

## 🔧 Advanced Usage

### Converting Large Databases

For large databases, use the verbose flag to monitor progress:
```bash
accdb2sqlite -v -a database.accdb
```

### Non-interactive Mode

For scripting or automation:
```bash
accdb2sqlite -n -a database.accdb
```

## ⚠️ Known Limitations

- Binary data types may not convert perfectly
- Access forms, reports, and macros are not converted
- Large tables require sufficient memory
- Some complex queries may need manual adjustment

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Commit your changes
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. Push to the branch
   ```bash
   git push origin feature/amazing-feature
   ```
5. Open a Pull Request

## 🐛 Troubleshooting

### Common Issues

1. **Missing Dependencies**
   ```bash
   # Check if mdbtools is installed
   which mdb-tables
   
   # Check if sqlite3 is installed
   which sqlite3
   ```

2. **Permission Denied**
   ```bash
   # Make sure the script is executable
   chmod +x accdb2sqlite.sh
   ```

3. **File Not Found**
   - Ensure the Access database path is correct
   - Check if the file is readable

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with by Mustafa Al-Jayyashee | [Report Issues](https://github.com/aljayyashee/accdb2sqlite/issues)