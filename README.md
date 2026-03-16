# Creative Mode for Desynced

A Creative Mode scenario mod for Desynced v1.0.

Fork of [lukask97/DesyncedModCreativeMode](https://github.com/lukask97/DesyncedModCreativeMode), updated for Desynced v1.0 (March 2026).

## Features

- **Mod settings menu** with toggleable features and customizable values
- All research unlocked
- Buildings for free (instant construction)
- Components for free
- Bots/Units for free
- Items for free
- Start with extra miner scouts (configurable amount)
- Equip starting scouts with power cells
- Customizable power cell power output
- Customizable power cell transfer radius
- Customizable scout view radius
- Starting lander with assembler, fabricator, power cell, and basic resources

## Installation

Subscribe on the Steam Workshop, or manually place the `creativemode` folder in your Desynced mods directory.

## Usage

1. Enable the mod in the Desynced mod menu
2. Configure settings in the mod options (checkboxes and custom values)
3. Start a new game and select the "Creative Mode" scenario

## Changes in v1.0

- Updated for Desynced v1.0 compatibility
- Added robust error handling (pcall protection) to prevent crashes from API changes
- Updated frame IDs with fallback support for older versions
- Fixed Default/Reset buttons in the options UI to properly commit values
- Fixed typos in the UI
- Safe property access for all data table modifications
