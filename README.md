# Python Scripts Manager

A sleek and powerful macOS application designed to help you manage, schedule, and execute Python scripts with ease. Built with SwiftUI, this application provides a modern interface for handling multiple Python scripts, complete with real-time execution monitoring and automated scheduling capabilities.

![CleanShot 2024-11-02 at 16 09 32](https://github.com/user-attachments/assets/23d654f4-5034-459b-9258-d0061a878024)


## Description

Python Scripts Manager is a native macOS application that streamlines the process of managing and executing Python scripts. It provides an intuitive interface for running scripts, monitoring their output in real-time, scheduling automated executions, and managing multiple scripts simultaneously through an elegant terminal-like interface.

## Features

### Script Management
- 📁 Easy script import through drag-and-drop or file picker
- 🗂 Organized script listing with detailed information
- ✏️ Custom naming and organization of scripts
- 🗑 Simple script removal (non-destructive)

### Execution Control
- ▶️ One-click script execution
- ⏹ Immediate script termination
- 👁 Real-time output monitoring
- ⌨️ Interactive input support for scripts requiring user interaction
- 🎯 Support for Control+C to terminate running scripts

### Advanced Terminal Features
- 📟 Multi-tab terminal interface
- 🔄 Real-time output streaming
- 📝 Command history
- 🎨 Monospaced font support
- 💻 Built-in terminal commands (help, clear, list, run, stop)

### Scheduling Capabilities
- ⏰ Flexible scheduling options:
  - One-time execution
  - Daily runs
  - Weekly runs on selected days
- 🕒 Custom time selection
- 📅 Next run time preview
- 🔄 Automatic rescheduling for recurring tasks

### User Interface
- 🎨 Native macOS look and feel
- 🌙 System-native dark mode support
- 💨 Smooth animations and transitions
- 🖱 Context-aware controls
- ⌨️ Keyboard shortcuts support

### Data Management
- 💾 Automatic state persistence
- 📊 Execution history tracking
- 🔒 Secure script reference storage

## Getting Started

### Prerequisites

1. **macOS System**
   - macOS 14.0 (Sonoma) or later

2. **Python Installation**
   - Python 3.x installed on your system
   - The application automatically detects Python installations in common locations:
     - `/opt/homebrew/bin/python3`
     - `/usr/local/bin/python3`
     - `/usr/bin/python3`
     - `/usr/bin/python`

3. **Xcode** (for development only)
   - Xcode 13.0 or later
   - Swift 5.5 or later

### Installation

1. Download the .dmg file from the repository
2. Mount the DMG file by double-clicking it
3. Drag Python Scripts Manager into your Applications folder
4. Eject the DMG
5. When first launching, you may need to right-click and select "Open" to bypass Gatekeeper
6. Grant necessary permissions when prompted

## Project Structure

```
Python_Scripts_Manager/
├── App/
│   ├── Python_Scripts_ManagerApp.swift   # Main app entry point
│   ├── AppDelegate.swift                 # App delegate handling
│   ├── AppState.swift                    # Global app state
│   └── ContentView.swift                 # Main content view
├── Models/
│   ├── Script.swift                      # Script model
│   ├── ScriptSchedule.swift             # Scheduling model
│   └── TerminalTab.swift                # Terminal tab model
├── ViewModels/
│   ├── ScriptListViewModel.swift        # Script list management
│   ├── ScriptScheduleViewModel.swift    # Schedule management
│   └── TerminalViewModel.swift          # Terminal interaction
├── Views/
│   ├── Components/
│   │   ├── TerminalInputField.swift     # Custom terminal input
│   │   ├── TerminalInputView.swift      # Input view
│   │   ├── TerminalOutputView.swift     # Output display
│   │   └── TerminalTabBar.swift         # Terminal tabs
│   ├── Main/
│   │   ├── HeaderView.swift             # App header
│   │   ├── ScriptListView.swift         # Script listing
│   │   └── TerminalView.swift           # Terminal view
│   └── Sheets/
│       └── ScriptScheduleView.swift      # Schedule configuration
├── Services/
│   ├── ScriptCoordinatorService.swift   # Central coordination
│   ├── ScriptExecutionService.swift     # Script execution
│   └── ScriptStorageService.swift       # Data persistence
├── Protocols/
│   ├── ScriptExecutable.swift           # Execution protocol
│   ├── ScriptSchedulable.swift          # Scheduling protocol
│   └── ScriptStorable.swift             # Storage protocol
└── Utils/
    ├── Constants.swift                   # App constants
    ├── Extensions/
    │   ├── UTType+Extension.swift       # UTType extensions
    │   └── View+Extension.swift         # SwiftUI extensions
    └── Helpers/
        └── ProcessHelper.swift           # Process utilities
```

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow Swift style guidelines
- Maintain existing code structure
- Add unit tests for new features
- Update documentation as needed
- Test on different macOS versions when possible

## License

Distributed under the MIT License. See `LICENSE` for more information.

```
MIT License

Copyright (c) 2024 Scott Santinho

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software...
```

## Acknowledgments

* [IconKitchen](https://icon.kitchen/) - For the simple yet elegant design of the Application Logo
* OpenAI's o1 models and Anthropic's Claude 3.5 Sonnet (New) - For assistance in code refactoring and optimization
* SwiftUI Community - For inspiration and best practices
* [Apple Developer Documentation](https://developer.apple.com/documentation) - For comprehensive API references
* All the contributors who have invested their time into making this project better
