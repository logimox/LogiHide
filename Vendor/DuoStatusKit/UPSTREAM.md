# DuoBar source provenance

Source: https://github.com/Mikeli7666/DuoBar
Commit: fc348a53a25855b7c9433583b4beae4eb256feeb
License: MIT; Copyright (c) 2026 Mike Li. See LICENSE.
Vendored and modified by logimox on 2026-11-06 for LogiHide.

The standalone app entrypoint and delegate are omitted. Models, services, UI,
status controller, settings, instance-lock utility and tests are retained.

Changes: a public integration wrapper borrows holzBar's status item; the host
keeps its click target, section identities and ownership. The popover includes
hiding/layout actions and calls the host's settings window. Invalidation stops
popover sampling without removing the borrowed status item. Launch/Dock settings
are handled by the host. Localization reads the package resource bundle, maps
DuoBar display text to LogiHide, and adds Swedish core labels. A DEBUG-only network
diagnostic tolerates an absent NSApplication in standalone tests. On macOS 27, concealment swaps the hosted indicator for a live native
NSButton image and reinserts the item once when entering that rendering mode,
so MenuBarAgent can draw it while assessment mode is active. Tests import
DuoStatusKit and read its resource bundle. LogiHideIntegrationTests cover the bridge.

The original MIT grant remains intact. The complete LogiHide work, including its
integration changes, is distributed under GPL v3.0 at the repository root.
