# Roblox Scripting Suite: Universal Library & Nexus Multi-Game Hub

This repository contains a professional-grade Roblox exploit suite featuring a highly polished UI library and a feature-rich multi-game script (Nexus).

## 🚀 Repository Contents

### 1. `l.lua` (UniversalLib)
A modern, secure, and animated UI library designed for Roblox exploits.
- **Features:**
  - **Premium UI:** Smooth fade transitions, modern color palette, and professional layout.
  - **Draggable Windows:** Supports both PC (Mouse) and Mobile (Touch) dragging.
  - **Rich Components:** Buttons, Toggles, Sliders, Dropdowns, Keybinds, and TextBoxes.
  - **Security:** Base64-encoded local key storage and UI anti-tamper protections.
  - **Identity Obfuscation:** Realistic fake usernames and UserIDs for focus-loss/streamer mode.
- **Usage:**
  ```lua
  local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaHost01/n/refs/heads/main/l.lua"))()
  ```

### 2. `MyScripts/1.lua` (Nexus Hub)
A high-performance multi-game script optimized for **Murder Mystery 2 (MM2)** and **Arsenal**.
- **Universal Features:**
  - **Aimbot Systems:** Camera Lock, Silent Aim (Magic Bullets), TriggerBot, and Team/FFA filters.
  - **Visuals (ESP):** Optimized Box ESP and 3D Highlights.
  - **Movement:** Fly (with speed control), Noclip, and Infinite Jump.
  - **God Mode:** Advanced "Immortal" method (Humanoid cloning and state-locking).
- **MM2 Exclusive Features:**
  - **Advanced Auto-Farm:** Map-aware dynamic pathing with a comprehensive coordinate database.
  - **X-Ray:** Wall transparency and role-colored player highlights.
  - **Kill Aura Visuals:** rotating neon ring around your character (Murderer only).
  - **Anti-Cheat Bypass:** Built-in velocity spoofing and CFrame walkspeed bypass.
  - **Performance:** Efficient role caching system.

### 3. `Sample.lua`
A reference script demonstrating how to integrate and use the `UniversalLib` (`l.lua`) in your own projects.

---

## 🛠️ Installation & Execution

To run the Nexus Hub, use the following loadstring in your preferred executor:

```lua
loadstring(readfile("MyScripts/1.lua"))()
```

*(Note: Ensure you have the `MyScripts` folder and `1.lua` file downloaded to your exploit's `workspace` directory, or use a web-based loadstring pointing to your raw GitHub file.)*

## 📜 License
This project is licensed under the **GNU Lesser General Public License v2.1**.

## 👥 Credits
- **BaHost01 / agente0981** - Main Developer & Holder
- **Nexus Team** - Combat Systems & Optimizations
