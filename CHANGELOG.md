# Changelog

All notable changes to this project will be documented in this file.

## [0.1.2]
- Added Combat Enhancements module (save/apply hooks) and wired it into profile save/apply and the TOC.
- Expanded synced CVars to include combat enhancements and floating combat text options.
- Chat channel sync now stores channel name/zone pairs and applies channels using frame registration when needed.
- Profile creation now prints confirmation and triggers a save.
- Removed debug logging from Edit Mode save.

## [0.1.1]
- New UI for operations (save, apply, discard, create/delete/select profiles).
- Added the ability to:
	- Create and switch custom profiles.
	- Select profiles from a dropdown.
	- Delete profiles from the UI.
	- Save settings and apply them via UI buttons.
	- Discard changes from the UI.
	- Reset the current profile via `/ss reset`.
	- Reset all profiles via `/ss resetall`.

## [0.1.0]
- Modules and capabilities:
	- ActionBars: Save and apply multi-action bar visibility toggles.
	- Chat: Save and apply chat window names, docking/lock/interactable states, colors, font size, message groups, and channels.
	- CVars: Save and apply selected CVars (currently: `autoLootDefault`).
	- EditMode: Save and apply the active edit mode layout (preset or custom by name).

