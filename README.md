# testapp (Sound Canvas)

A modern Flutter application for music, canvas, and multimedia experiences.

---

## 🚀 Quick Environment Setup

Automated scripts are provided to install and configure **Flutter SDK, Dart, Android Studio, Android SDK**, and all required **environment variables** (`ANDROID_HOME`, `JAVA_HOME`, and `PATH`).

### 🪟 Windows Setup (PowerShell)

Open PowerShell (Run as Administrator recommended for seamless package installation) and execute:

```powershell
# Run the setup script
powershell -ExecutionPolicy Bypass -File .\setup.ps1

# Or run the full script with optional custom parameters
powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1
```

**What the Windows script does:**
1. Checks for and installs **Git** (via `winget` if missing).
2. Checks for and installs **Flutter SDK & Dart** (via `winget` or direct Google storage download).
3. Checks for and installs **Android Studio** (via `winget`).
4. Configures persistent User Environment Variables:
   - `ANDROID_HOME` & `ANDROID_SDK_ROOT` (`%LOCALAPPDATA%\Android\Sdk`)
   - `JAVA_HOME` (Points to Android Studio's bundled JBR runtime)
   - Appends Flutter `bin`, `platform-tools`, and `cmdline-tools\latest\bin` to `PATH`.
5. Connects Flutter with the Android SDK and auto-accepts Android licenses.
6. Runs `flutter doctor -v` to verify health.

---

### 🍏 macOS Setup (Terminal)

Open Terminal in the project root directory and run:

```bash
# Make sure the script is executable (already set) and run:
./setup.sh

# Or directly:
./setup_macos.sh
```

**What the macOS script does:**
1. Verifies Apple Silicon (`arm64`) or Intel (`x86_64`) architecture and Xcode Command Line Tools.
2. Detects Homebrew (`brew`) and offers automated installation if missing.
3. Configures **Flutter SDK & Dart** (in `~/development/flutter` or via Homebrew).
4. Verifies **Android Studio** in `/Applications/Android Studio.app` and defaults Android SDK to `~/Library/Android/sdk`.
5. Configures persistent environment variables in `~/.zshrc` and `~/.bash_profile`:
   - `ANDROID_HOME` & `ANDROID_SDK_ROOT`
   - `JAVA_HOME` (Points to Android Studio JBR)
   - Updates `PATH` with Flutter and Android platform/cmdline tools.
6. Configures Flutter Android paths, accepts Android licenses, and runs `flutter doctor -v`.

> **Note:** After the script finishes, run `source ~/.zshrc` or restart your terminal / VS Code window to apply new environment variables.

---

## Getting Started

Once your environment is set up:

```bash
# Get project dependencies
flutter pub get

# Run the app
flutter run
```

### Helpful Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Unity LevelPlay Setup](file:///Users/mac/Desktop/sound_canvas/UNITY_LEVELPLAY_FULL_SETUP.md)

