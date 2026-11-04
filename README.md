# Flatpak for Aesthetic FHS | [![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

Downstream patch set for Flatpak compatibility with Nitrux's Aesthetic FHS Gen. 2.

## Context

Flatpak builds its D-Bus proxy namespace by enumerating the root directory. Aesthetic FHS hides selected FHS entries from directory listings while preserving direct pathname access, so Flatpak's root enumeration can omit paths such as `/usr` and `/lib`.

This repository carries a small patch that checks the required root entries by pathname before adding them to the proxy namespace.

## Runtime Requirements

Nitrux 7.1.0 and newer.

# Licensing

This repository contains files under multiple licenses.

- Build and packaging automation is licensed under **BSD-3-Clause** (see `LICENSE`).
- The Flatpak patch modifies `common/flatpak-run-dbus.c`, which is licensed under **LGPL-2.1-or-later**. The patch is distributed under that license.
- Debian packaging files are obtained from [Debian's Flatpak packaging repository](https://salsa.debian.org/debian/flatpak); see its `debian/copyright` file for its licensing.

# Issues

If you find problems with the contents of this repository, please create an issue and use the **🐞 Bug report** template.

## Submitting a bug report

Before submitting a bug, you should look at the [existing bug reports](https://github.com/Nitrux/flatpak-afhs/issues) to verify that no one has reported the bug already.

©2026 Nitrux Latinoamericana S.C.
