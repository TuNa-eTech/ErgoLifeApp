#!/bin/bash

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if fvm is available
if ! command -v fvm &> /dev/null; then
    print_warning "FVM not found, using flutter directly"
    FLUTTER_CMD="flutter"
    DART_CMD="dart"
else
    FLUTTER_CMD="fvm flutter"
    DART_CMD="fvm dart"
fi

echo ""
echo "╔════════════════════════════════════════╗"
echo "║     Flutter Code Generator By tuna     ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Main menu
echo "Choose what to generate:"
echo "1) 📦 Generate lib"
echo "2) 🧪 Generate test"
echo "3) 🌐 Generate slang (translations)"
echo "4) 🖼️  Generate assets"
echo "5) 🎯 Generate specific file"
echo "6) 📁 Generate specific folder"
echo "7) 🚀 Generate all"
echo "8) 🧹 Clean and generate all"
echo "9) 👀 Watch mode (auto-regenerate)"
read -p "Enter choice [1-9]: " choice

# Conflict handling option
echo ""
echo "How to handle conflicts?"
echo "1) Skip conflicts (safe, recommended)"
echo "2) Delete conflicting outputs only"
echo "3) Delete all and regenerate"
read -p "Enter choice [1-3, default: 1]: " conflictChoice
conflictChoice=${conflictChoice:-1}

deleteOption=""
case $conflictChoice in
    1)
        deleteOption=""
        print_info "Will skip conflicting files (safe mode)"
        ;;
    2)
        deleteOption="--delete-conflicting-outputs"
        print_warning "Will delete conflicting outputs"
        ;;
    3)
        print_warning "Will delete all generated files and regenerate"
        read -p "Are you sure? This will delete ALL .g.dart, .freezed.dart files (y/n): " confirmDelete
        if [ "$confirmDelete" == "y" ]; then
            print_info "Deleting old generated files..."
            find . -type f \( -name "*.g.dart" -o -name "*.freezed.dart" -o -name "*.gen.dart" \) -not -path "*/.*" -delete
            print_success "Deleted old files"
        else
            print_info "Cancelled deletion, continuing with normal build..."
        fi
        ;;
esac

# Watch mode option (for applicable choices)
watchMode=""
if [ "$choice" != "3" ] && [ "$choice" != "7" ] && [ "$choice" != "8" ] && [ "$choice" != "9" ]; then
    read -p "Use watch mode? (y/n, default: n): " watchChoice
    watchChoice=${watchChoice:-n}
    if [ "$watchChoice" == "y" ]; then
        watchMode="watch"
    else
        watchMode="build"
    fi
fi

# Start time
start_time=$(date +%s)

echo ""
echo "════════════════════════════════════════"
echo ""

case $choice in
    1)
        print_info "Generating lib..."
        $FLUTTER_CMD pub run build_runner $watchMode $deleteOption --build-filter="lib/**"
        ;;
    2)
        print_info "Generating test..."
        $FLUTTER_CMD pub run build_runner $watchMode $deleteOption --build-filter="test/**"
        ;;
    3)
        print_info "Generating slang translations..."
        $DART_CMD run slang
        ;;
    4)
        print_info "Generating assets..."
        $FLUTTER_CMD pub run build_runner $watchMode $deleteOption --build-filter="lib/gen/assets.gen.dart"
        ;;
    5)
        read -p "Enter file path (e.g., lib/models/user.dart): " filePath
        if [ -z "$filePath" ]; then
            print_error "File path cannot be empty"
            exit 1
        fi
        if [ ! -f "$filePath" ]; then
            print_warning "File does not exist: $filePath"
            read -p "Continue anyway? (y/n): " continueChoice
            if [ "$continueChoice" != "y" ]; then
                exit 1
            fi
        fi
        print_info "Generating specific file: $filePath"
        $FLUTTER_CMD pub run build_runner $watchMode $deleteOption --build-filter="$filePath"
        ;;
    6)
        read -p "Enter folder path (e.g., lib/models): " folderPath
        if [ -z "$folderPath" ]; then
            print_error "Folder path cannot be empty"
            exit 1
        fi
        if [ ! -d "$folderPath" ]; then
            print_warning "Folder does not exist: $folderPath"
            read -p "Continue anyway? (y/n): " continueChoice
            if [ "$continueChoice" != "y" ]; then
                exit 1
            fi
        fi
        print_info "Generating specific folder: $folderPath"
        $FLUTTER_CMD pub run build_runner $watchMode $deleteOption --build-filter="$folderPath/**"
        ;;
    7)
        print_info "Generating all..."
        echo ""
        print_info "Step 1/2: Running build_runner..."
        $FLUTTER_CMD pub run build_runner build $deleteOption
        if [ $? -eq 0 ]; then
            print_success "Build runner completed"
        else
            print_error "Build runner failed"
            exit 1
        fi
        echo ""
        print_info "Step 2/2: Running slang..."
        $DART_CMD run slang
        if [ $? -eq 0 ]; then
            print_success "Slang completed"
        else
            print_error "Slang failed"
            exit 1
        fi
        ;;
    8)
        print_info "Cleaning and generating all..."
        echo ""
        print_info "Step 1/3: Cleaning build cache..."
        $FLUTTER_CMD clean
        rm -rf .dart_tool/build
        print_success "Clean completed"
        echo ""
        print_info "Step 2/3: Running build_runner..."
        $FLUTTER_CMD pub run build_runner build $deleteOption
        if [ $? -eq 0 ]; then
            print_success "Build runner completed"
        else
            print_error "Build runner failed"
            exit 1
        fi
        echo ""
        print_info "Step 3/3: Running slang..."
        $DART_CMD run slang
        if [ $? -eq 0 ]; then
            print_success "Slang completed"
        else
            print_error "Slang failed"
            exit 1
        fi
        ;;
    9)
        print_info "Starting watch mode for all files..."
        print_warning "Press Ctrl+C to stop"
        $FLUTTER_CMD pub run build_runner watch $deleteOption
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

# Calculate execution time
end_time=$(date +%s)
execution_time=$((end_time - start_time))

if [ $? -eq 0 ]; then
    echo ""
    print_success "Generation completed successfully! ⚡"
    print_info "Execution time: ${execution_time}s"
else
    echo ""
    print_error "Generation failed!"
    exit 1
fi

# Optional: Show generated files
if [ "$choice" != "9" ]; then
    read -p "Show recently generated files? (y/n, default: n): " showFiles
    if [ "$showFiles" == "y" ]; then
        echo ""
        print_info "Recently generated files (last 5 minutes):"
        find . -name "*.g.dart" -o -name "*.freezed.dart" -o -name "*.gen.dart" | grep -E "\.g\.dart$|\.freezed\.dart$|\.gen\.dart$" | xargs ls -lt 2>/dev/null | head -10
    fi
fi

echo ""