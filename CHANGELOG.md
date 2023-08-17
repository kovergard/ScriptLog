# Changelog for ScriptLog

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- New function Close-ScriptLog added, to allow for closing active logs during a session.

### Fixed

- It is no longer possible to have two ScrtipLogs using the same file.

### Changed

- The parameter AppendDateTime in function New-ScriptLog is now a switch instead of a boolean.
- Internal test quality improved.

## [0.3.1] - 2022-07-14

### Changed

- Build pipeline now run in batch mode

## [0.3.0] - 2022-07-14

### Changed

- README updated with build info and link to gallery.
- License file added.
- Tags and link to Github repository added to metadata for easier discovery.

## [0.2.0] - 2022-07-13

### Added

- README.md added with installation information and examples.

### Changed

- Moved from private repo to public Github site https://github.com/kovergard/ScriptLog
- Changed code coverage parameters to allow publishing
- First version published to PowerShell Gallery