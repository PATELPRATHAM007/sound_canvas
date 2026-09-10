#!/usr/bin/env bash

# ==============================================================================
# Automated Flutter, Dart, Android Studio, and Global Environment Setup (macOS)
# ==============================================================================

set -e

# ANSI Color codes
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
RED="\033[0;31m"
NC="\033[0m" # No Color

print_header() {
  echo ""
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "  ${BOLD}$1${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  echo ""
}

print_success() {
  echo -e "${GREEN}[✓] $1${NC}"
}

print_info() {
  echo -e "${BLUE}[i] $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}[!] $1${NC}"
}

print_error() {
  echo -e "${RED}[x] $1${NC}"
}

download_and_extract_zip() {
  local URL="$1"
  local ZIP_PATH="$2"
  local DEST_DIR="$3"
  local DESC="$4"

  print_info "Downloading $DESC (with progress bar)..."
  mkdir -p "$(dirname "$ZIP_PATH")"
  mkdir -p "$DEST_DIR"

  # Use curl with interactive progress bar
  curl --progress-bar -fL "$URL" -o "$ZIP_PATH"
  print_info "Extracting $DESC to $DEST_DIR..."
  unzip -q -o "$ZIP_PATH" -d "$DEST_DIR"
  rm -f "$ZIP_PATH"
  print_success "$DESC installed successfully."
}

print_header "Flutter & Android Studio Complete Setup (macOS)"

# ------------------------------------------------------------------------------
# 1. OS & Architecture Check
# ------------------------------------------------------------------------------
OS_TYPE="$(uname -s)"
ARCH_TYPE="$(uname -m)"

if [ "$OS_TYPE" != "Darwin" ]; then
  print_warning "This script is tailored for macOS. Detected OS: $OS_TYPE"
  print_info "For Windows, please run: powershell -ExecutionPolicy Bypass -File .\\setup.ps1"
  if [ "$OS_TYPE" != "Linux" ]; then
    print_error "Unsupported operating system. Exiting."
    exit 1
  fi
fi

print_success "Operating System: macOS ($ARCH_TYPE)"

# ------------------------------------------------------------------------------
# 2. Step 1: Xcode Command Line Tools Check & Auto-Install
# ------------------------------------------------------------------------------
print_header "Step 1: Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
  XCODE_PATH="$(xcode-select -p)"
  print_success "Xcode Command Line Tools already installed at: $XCODE_PATH"
else
  print_info "Xcode Command Line Tools not found. Initiating installation..."
  xcode-select --install || true
  print_warning "Please complete the Apple dialog prompt if shown."
fi

# ------------------------------------------------------------------------------
# 3. Step 2: Homebrew Package Manager Check & Auto-Install
# ------------------------------------------------------------------------------
print_header "Step 2: Homebrew Package Manager"
HAS_BREW=false
if command -v brew &>/dev/null; then
  HAS_BREW=true
  BREW_VER="$(brew --version | head -n 1)"
  print_success "Homebrew is already installed: $BREW_VER"
else
  # Check standard homebrew path if not in current PATH
  if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    HAS_BREW=true
    print_success "Homebrew detected at /opt/homebrew/bin/brew."
  elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
    HAS_BREW=true
    print_success "Homebrew detected at /usr/local/bin/brew."
  else
    print_info "Homebrew not found. Installing Homebrew automatically..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
    if [ -f "/opt/homebrew/bin/brew" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      HAS_BREW=true
    elif [ -f "/usr/local/bin/brew" ]; then
      eval "$(/usr/local/bin/brew shellenv)"
      HAS_BREW=true
    fi
  fi
fi

# ------------------------------------------------------------------------------
# 4. Step 3: Flutter & Dart SDK Check & Auto-Install
# ------------------------------------------------------------------------------
print_header "Step 3: Flutter & Dart SDK"
FLUTTER_BIN=""
FLUTTER_DIR=""

# Check if flutter binary is already in PATH
if command -v flutter &>/dev/null; then
  FLUTTER_BIN="$(dirname "$(command -v flutter)")"
  FLUTTER_DIR="$(dirname "$FLUTTER_BIN")"
  print_success "Flutter is already installed and active: $FLUTTER_DIR"
else
  CANDIDATES=(
    "$HOME/development/flutter"
    "$HOME/flutter"
    "/opt/homebrew/Caskroom/flutter"
    "/usr/local/Caskroom/flutter"
  )

  for candidate in "${CANDIDATES[@]}"; do
    if [ -f "$candidate/bin/flutter" ]; then
      FLUTTER_DIR="$candidate"
      FLUTTER_BIN="$candidate/bin"
      print_success "Found existing Flutter SDK at: $FLUTTER_DIR"
      break
    fi
  done

  # If not installed anywhere, auto-download/clone
  if [ -z "$FLUTTER_DIR" ]; then
    TARGET_DIR="$HOME/development/flutter"
    mkdir -p "$HOME/development"
    print_info "Flutter SDK not found. Setting up official Flutter SDK in: $TARGET_DIR"

    if [ "$HAS_BREW" = true ]; then
      print_info "Attempting installation via Homebrew Cask..."
      brew install --cask flutter || true
      if command -v flutter &>/dev/null; then
        FLUTTER_BIN="$(dirname "$(command -v flutter)")"
        FLUTTER_DIR="$(dirname "$FLUTTER_BIN")"
      fi
    fi

    # Fallback to direct official Git clone
    if [ -z "$FLUTTER_DIR" ]; then
      print_info "Cloning Flutter SDK stable branch into: $TARGET_DIR (with progress)..."
      git clone --progress https://github.com/flutter/flutter.git -b stable "$TARGET_DIR"
      FLUTTER_DIR="$TARGET_DIR"
      FLUTTER_BIN="$TARGET_DIR/bin"
    fi
    print_success "Flutter SDK configured at: $FLUTTER_DIR"
  fi
fi

# Set proper execution permissions
if [ -d "$FLUTTER_BIN" ]; then
  chmod -R +x "$FLUTTER_BIN" 2>/dev/null || true
fi
export PATH="$FLUTTER_BIN:$PATH"

# ------------------------------------------------------------------------------
# 5. Step 4: Android Studio Check & Auto-Install
# ------------------------------------------------------------------------------
print_header "Step 4: Android Studio"
ANDROID_STUDIO_APP="/Applications/Android Studio.app"

if [ -d "$ANDROID_STUDIO_APP" ]; then
  print_success "Android Studio is already installed at: $ANDROID_STUDIO_APP"
else
  print_info "Android Studio not found. Installing Android Studio..."
  if [ "$HAS_BREW" = true ]; then
    brew install --cask android-studio || true
    if [ -d "$ANDROID_STUDIO_APP" ]; then
      print_success "Android Studio installed successfully."
    fi
  else
    print_warning "Homebrew not found. Please install Android Studio from https://developer.android.com/studio"
  fi
fi

# ------------------------------------------------------------------------------
# 6. Step 5: Android SDK, Platform-Tools & Command-Line Tools Check & Auto-Install
# ------------------------------------------------------------------------------
print_header "Step 5: Android SDK & Command-Line Tools"
ANDROID_SDK="$HOME/Library/Android/sdk"
mkdir -p "$ANDROID_SDK"
print_success "Android SDK root directory: $ANDROID_SDK"

# 1. Platform-Tools (adb, fastboot)
ADB_BIN="$ANDROID_SDK/platform-tools/adb"
if [ -f "$ADB_BIN" ]; then
  print_success "Android Platform-Tools (adb) are already installed."
else
  print_info "Android Platform-Tools missing. Downloading latest from Google..."
  download_and_extract_zip \
    "https://dl.google.com/android/repository/platform-tools-latest-darwin.zip" \
    "/tmp/platform_tools_mac.zip" \
    "$ANDROID_SDK" \
    "Android Platform-Tools"
fi
chmod -R +x "$ANDROID_SDK/platform-tools" 2>/dev/null || true

# 2. Command-Line Tools (sdkmanager, avdmanager)
SDK_MGR="$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager"
if [ -f "$SDK_MGR" ]; then
  print_success "Android Command-Line Tools are already installed."
else
  print_info "Android Command-Line Tools missing. Downloading latest from Google..."
  mkdir -p "$ANDROID_SDK/cmdline-tools"
  download_and_extract_zip \
    "https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip" \
    "/tmp/cmdline_tools_mac.zip" \
    "$ANDROID_SDK/cmdline-tools" \
    "Android Command-Line Tools"

  # Standardize directory structure into 'latest'
  if [ -d "$ANDROID_SDK/cmdline-tools/cmdline-tools" ]; then
    rm -rf "$ANDROID_SDK/cmdline-tools/latest" 2>/dev/null || true
    mv "$ANDROID_SDK/cmdline-tools/cmdline-tools" "$ANDROID_SDK/cmdline-tools/latest"
  fi
fi
chmod -R +x "$ANDROID_SDK/cmdline-tools" 2>/dev/null || true

# ------------------------------------------------------------------------------
# 7. Step 6: Java Runtime (JDK / JBR) Detection
# ------------------------------------------------------------------------------
print_header "Step 6: Java Runtime (JDK / JBR)"
JAVA_HOME_PATH=""
JBR_CANDIDATE="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

if [ -d "$JBR_CANDIDATE" ]; then
  JAVA_HOME_PATH="$JBR_CANDIDATE"
  print_success "Detected Android Studio JBR Java runtime at: $JAVA_HOME_PATH"
elif [ -n "$JAVA_HOME" ] && [ -d "$JAVA_HOME" ]; then
  JAVA_HOME_PATH="$JAVA_HOME"
  print_success "Using existing JAVA_HOME: $JAVA_HOME_PATH"
elif command -v /usr/libexec/java_home &>/dev/null; then
  SYS_JAVA="$(/usr/libexec/java_home 2>/dev/null || true)"
  if [ -n "$SYS_JAVA" ] && [ -d "$SYS_JAVA" ]; then
    JAVA_HOME_PATH="$SYS_JAVA"
    print_success "Using macOS system Java: $JAVA_HOME_PATH"
  fi
fi

# ------------------------------------------------------------------------------
# 8. Step 7: Configure Persistent Global Environment Variables
# ------------------------------------------------------------------------------
print_header "Step 7: Configuring Global Persistent Environment Variables"

update_profile_file() {
  local PROFILE_FILE="$1"
  local START_MARKER="# >>> sound_canvas Flutter & Android Environment >>>"
  local END_MARKER="# <<< sound_canvas Flutter & Android Environment <<<"

  touch "$PROFILE_FILE"

  local CONFIG_BLOCK="$START_MARKER
export ANDROID_HOME=\"$ANDROID_SDK\"
export ANDROID_SDK_ROOT=\"$ANDROID_SDK\""

  if [ -n "$JAVA_HOME_PATH" ]; then
    CONFIG_BLOCK="$CONFIG_BLOCK
export JAVA_HOME=\"$JAVA_HOME_PATH\""
  fi

  CONFIG_BLOCK="$CONFIG_BLOCK
export PATH=\"\$PATH:$FLUTTER_BIN:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/tools/bin:\$ANDROID_HOME/tools\"
$END_MARKER"

  # Cleanly replace block if already present, or append
  if grep -qF "$START_MARKER" "$PROFILE_FILE"; then
    sed -i '' "/$START_MARKER/,/$END_MARKER/d" "$PROFILE_FILE" 2>/dev/null || true
  fi

  echo "" >> "$PROFILE_FILE"
  echo "$CONFIG_BLOCK" >> "$PROFILE_FILE"
  print_success "Configured environment variables in: $PROFILE_FILE"
}

# Update all shell startup profiles so any shell or terminal inherits them permanently
update_profile_file "$HOME/.zshrc"
update_profile_file "$HOME/.bash_profile"
if [ -f "$HOME/.bashrc" ]; then update_profile_file "$HOME/.bashrc"; fi
if [ -f "$HOME/.profile" ]; then update_profile_file "$HOME/.profile"; fi

# Also configure system-wide /etc/paths.d if writable
if [ -w "/etc/paths.d" ]; then
  cat <<EOF > /etc/paths.d/sound_canvas_flutter
$FLUTTER_BIN
$ANDROID_SDK/platform-tools
$ANDROID_SDK/cmdline-tools/latest/bin
EOF
  print_success "Added system-wide PATH in /etc/paths.d/sound_canvas_flutter"
fi

# Export into current execution session
export ANDROID_HOME="$ANDROID_SDK"
export ANDROID_SDK_ROOT="$ANDROID_SDK"
if [ -n "$JAVA_HOME_PATH" ]; then export JAVA_HOME="$JAVA_HOME_PATH"; fi
export PATH="$PATH:$FLUTTER_BIN:$ANDROID_SDK/platform-tools:$ANDROID_SDK/cmdline-tools/latest/bin"

# ------------------------------------------------------------------------------
# 9. Step 8: Configure Flutter Android Paths & Accept Licenses
# ------------------------------------------------------------------------------
print_header "Step 8: Configuring Flutter Toolchain & Licenses"

if command -v flutter &>/dev/null; then
  flutter config --android-sdk "$ANDROID_SDK" >/dev/null
  if [ -d "$ANDROID_STUDIO_APP" ]; then
    flutter config --android-studio-dir "$ANDROID_STUDIO_APP" >/dev/null
  fi
  if [ -n "$JAVA_HOME_PATH" ]; then
    flutter config --jdk-dir "$JAVA_HOME_PATH" >/dev/null
  fi
  print_success "Flutter toolchain successfully bound to Android SDK & Java runtime."

  print_info "Accepting all Android SDK licenses..."
  if yes 2>/dev/null | flutter doctor --android-licenses &>/dev/null; then
    print_success "All Android licenses accepted."
  else
    print_warning "Android licenses could not be auto-accepted. You can run 'flutter doctor --android-licenses' manually."
  fi

  # ------------------------------------------------------------------------------
  # 10. Step 9: System Verification (Flutter Doctor)
  # ------------------------------------------------------------------------------
  print_header "Step 9: System Verification (flutter doctor -v)"
  flutter doctor -v || true
else
  print_warning "Flutter executable not found in current PATH. Please restart terminal to verify."
fi

print_header "Setup Completed Successfully!"
echo -e "${GREEN}All development tools and persistent environment variables are locked in globally.${NC}"
echo -e "${GREEN}No need to run this setup again for this system.${NC}"
echo ""
