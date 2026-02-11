# Changelog

## [5.05.2144] - 2026-02-11

### Fixed
- **Camera Offset Indicator:** Fixed a runtime error caused by a missing `hideTimerName` variable.
- **Context Sensitivity:**
  - Removed hardcoded numeric constants; now uses proper ESO API constants for better compatibility.
  - Added safety checks (`tonumber`) when retrieving settings to prevent type errors.
  - Expanded comments regarding sprint detection limitations (API constraints).
- **Core:** Added nil-check for `savedVars` in debug functions to prevent initialization errors.
- **Camera Hold:** Replaced recursive `zo_callLater` loops with `EVENT_MANAGER:RegisterForUpdate` for smoother and more reliable camera movement when holding keys.

### Changed
- **Internal Architecture:**
  - Created `Modules/Utils.lua` to de-duplicate utility functions (`Clamp`, `GetTimeMs`, etc.) across 6 modules.
  - Removed redundant `FOXUltimateCamera` namespace declarations in multiple files to clean up the codebase.

### Added
- **README:** added comprehensive documentation and installation instructions.
