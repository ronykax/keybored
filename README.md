# Keybored 

A macOS app that lets you bind system-wide hotkeys to actions.

Whether you want to control Spotify, launch applications, or trigger automation scripts, Keybored executes them instantly in the background.

---

## Installation

You can install Keybored using [Homebrew](https://brew.sh/):

```bash
brew tap ronykax/apps
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
Keybored automatically creates a `~/keybored.json` file on first launch. If you'd prefer to set it up manually beforehand, you can create it yourself:
```bash
touch ~/keybored.json
```
*(Alternatively, click the **folder icon** in the main window to show the file directly in Finder.*

### 2. Configure Your Hotkeys
Add your shortcut mappings in the following JSON array format:

```json
[
  {
    "modifiers": ["cmd", "shift", "ctrl", "opt"],
    "key": "space",
    "binary": "/usr/bin/osascript",
    "arguments": ["-e", "tell application \"Spotify\" to playpause"]
  }
]
```

### 3. Reload Your Configuration
Whenever you make changes to `~/keybored.json`, you need to reload the configurations in Keybored:
- **Menu Bar Icon:** Click on the Keybored menu bar icon and select **Reload**.
- **Main Window:** Open the window and click the **Reload** button.

---

## Hyper Key

For conflict-free hotkeys, Keybored includes an optional Hyper Key feature which turns

Holding **Caps Lock** acts as if `Control` + `Option` + `Command` + `Shift` are all pressed together.

### Enabling the Hyper Key
1. Open the Keybored window.
2. Under the **Hyper Key** section, toggle **Remap Caps Lock** on.
3. In your `~/keybored.json`, set your shortcut modifier list to use all four modifiers:
    ```json
    "modifiers": ["cmd", "shift", "ctrl", "opt"]
    ```

---

## Configuration Reference

| Key | Type | Description |
| :--- | :--- | :--- |
| `modifiers` | `string[]` | Modifier keys that trigger the action: `"cmd"`, `"shift"`, `"ctrl"`, `"opt"` |
| `key` | `string` | The key to press (case-insensitive). See supported keys below. |
| `binary` | `string` | Absolute path to the executable, e.g. `"/usr/bin/osascript"` |
| `arguments` | `string[]` | Arguments passed to the executable, e.g. `["-e", "tell application..."]` |

### Supported Keys
- **Special:** `"space"`, `"return"`, `"tab"`, `"escape"`, `"delete"`, `"fwddelete"`, `"home"`, `"end"`, `"pageup"`, `"pagedown"`
- **Arrow:** `"left"`, `"right"`, `"up"`, `"down"`
- **Function:** `"f1"` through `"f12"`
- **Alphanumeric:** `"a"` to `"z"`, `"0"` to `"9"`
- **Symbols:** `"-"`, `"="`, `"["`, `"]"`, `";"`, `"'"` (quote), `","`, `"."`, `"/"`, `"\\"` (backslash), `` "`" `` (backtick)
