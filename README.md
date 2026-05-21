# Keybored 

A lightweight, high-performance macOS utility that lets you bind system-wide hotkeys to custom system actions. An action is simply a binary executable paired with arguments.

Whether you want to control Spotify, launch applications, or trigger automation scripts, Keybored executes them instantly in the background.

---

## Installation

You can install Keybored using [Homebrew](https://brew.sh/):

```bash
brew tap ronykax/keybored
brew install --cask keybored
```

> [!TIP]
> When installed via Homebrew, quarantine removal is handled automatically. If installing manually, you can bypass the Gatekeeper block by running:
> ```bash
> xattr -d com.apple.quarantine /Applications/Keybored.app
> ```

---

## Getting Started

### 1. Create your Configuration File
Keybored reads its shortcuts from a JSON file located in your user home directory: `~/keybored.json`.

Create this file using your favorite text editor:
```bash
touch ~/keybored.json
```
*(Alternatively, click the **folder icon** in the Keybored settings window to open the directory directly in Finder).*

### 2. Configure Your Hotkeys
Add your shortcut mappings to `~/keybored.json` in the following JSON array format:

```json
[
  {
    "modifiers": ["cmd", "shift", "ctrl", "opt"],
    "key": "space",
    "binary": "/usr/bin/osascript",
    "arguments": ["-e", "tell application \"Spotify\" to playpause"]
  },
  {
    "modifiers": ["cmd", "opt"],
    "key": "t",
    "binary": "/usr/bin/open",
    "arguments": ["-a", "Terminal"]
  }
]
```

### 3. Reload Your Configuration
Whenever you make changes to `~/keybored.json`, you need to reload the configurations in Keybored:
- **Menu Bar Icon:** Click on the Keybored status bar icon and select **Reload**.
- **Settings Window:** Open the main settings interface and click the **Reload** button.

---

## Hyper Key

To avoid conflicts with built-in macOS shortcuts, Keybored includes an optional Hyper Key feature that turns **Caps Lock** into a Hyper key.

Holding **Caps Lock** acts as if `Control` + `Option` + `Command` + `Shift` are all pressed together. Since this combination is rarely used by macOS or applications, it creates a separate shortcut layer with fewer conflicts.

### Enabling the Hyper Key
1. Open the Keybored **Settings** window.
2. Under the **Hyper Key** section, toggle **Remap Caps Lock** on.
3. In your `~/keybored.json`, set your shortcut modifier list to use all four modifiers:
   ```json
   "modifiers": ["cmd", "shift", "ctrl", "opt"]

---

## Configuration Reference

Each object in the configuration array supports the following properties:

| Key | Type | Description | Example |
| :--- | :--- | :--- | :--- |
| `modifiers` | Array of Strings | The key modifiers required to trigger the action. Valid options: `"cmd"`, `"shift"`, `"ctrl"`, `"opt"`. | `["cmd", "ctrl"]` |
| `key` | String | The target key to press (case-insensitive). See below for supported keys. | `"space"`, `"escape"`, `"a"` |
| `binary` | String | Absolute path to the binary or script executable. | `"/usr/bin/osascript"`, `"/bin/zsh"` |
| `arguments` | Array of Strings | Arguments to pass to the executable. | `["-e", "tell application..."]` |

### Supported Key Strings
- **Special Keys:** `"space"`, `"return"`, `"tab"`, `"escape"`, `"delete"`, `"fwddelete"`, `"home"`, `"end"`, `"pageup"`, `"pagedown"`
- **Arrow Keys:** `"left"`, `"right"`, `"up"`, `"down"`
- **Function Keys:** `"f1"` through `"f12"`
- **Alphanumeric:** `"a"` to `"z"`, `"0"` to `"9"`
- **Symbols:** `"-"`, `"="`, `"["`, `"]"`, `";"`, `"'"` (quote), `","`, `"."`, `"/"`, `"\\"` (backslash), `"`"` (backtick)
