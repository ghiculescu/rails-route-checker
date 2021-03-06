# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added

### Changed

### Fixed

### Removed

> _Add your own contributions to the next release on a new line above this; please include your name too._
> _Please don't set a new version._

## [0.2.7] - 2020-10-26
### Added
- Support for Haml 5.2

## [0.2.5] - 2019-06-11
### Added
- Support for Haml 5.1

## [0.2.4] - 2018-11-26
### Fixed
- Crash if using Haml 5

## [0.2.3] - 2018-04-15
### Fixed
- Handle implicit rendering by searching for views based on controller's lookup context - [@palkan](https://github.com/palkan)
- Correct exit code if there is a single violation - [@ghiculescu](https://github.com/ghiculescu)

## [0.2.2] - 2017-12-13
### Changed
- Replace system bash calls with built-in Ruby methods

### Fixed
- Controller whitelist filter now works when parsing view files

## [0.2.1] - 2017-12-13
### Changed
- Removed `L` from files to fix output to make them clickable in newer terminals

## [0.2.0] - 2017-12-13
### Added
- AST parsing for Ruby code (replaces regex searching)
- AST parsing for Haml views (replaces regex searching)
- AST parsing for ERb views

[Unreleased]: https://github.com/daveallie/rails-route-checker/compare/0.2.7...HEAD
[0.2.7]: https://github.com/daveallie/rails-route-checker/compare/0.2.5...0.2.7
[0.2.5]: https://github.com/daveallie/rails-route-checker/compare/0.2.4...0.2.5
[0.2.4]: https://github.com/daveallie/rails-route-checker/compare/0.2.3...0.2.4
[0.2.3]: https://github.com/daveallie/rails-route-checker/compare/0.2.2...0.2.3
[0.2.2]: https://github.com/daveallie/rails-route-checker/compare/0.2.1...0.2.2
[0.2.1]: https://github.com/daveallie/rails-route-checker/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/daveallie/rails-route-checker/compare/0.1.1...0.2.0
