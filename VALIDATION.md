# Verifiering av LogiHide 0.1.0

Kontrollerat lokalt den 6 november 2026 på macOS 27.2, med Xcode 27.0 och Swift 6.4.

## Godkända kontroller

- Release-bygge för arm64 och x86_64 genom `Scripts/build-logihide.sh`.
- 1 476 kärntester från holzBar, utan fel.
- 331 tester i DuoStatusKit: 325 godkända och sex uttryckligen överhoppade hårdvarutester, utan fel.
- 14 testfall för signaturkontrollen, samtliga med väntat resultat.
- Appen och dess enda inbäddade hjälpramverk klarar signaturkontrollen och `codesign --verify --deep --strict`.
- Båda licenstexterna och DuoStatusKit:s språkresurser ingår i appen.
- GUI: appen startar, visar behörighetsfönstret och öppnar inställningarna efter godkännande. Layoutvyn visar sparade synliga och dolda appar.

Regressionstestet för menyikonen kontrollerar att döljläget levererar en riktig, icke-transparent NSButton-bild, behåller klickmottagaren och kan växla tillbaka till SwiftUI-vyn. Detta kompletterar den riktiga menyradskontrollen; ett enhetstest bevisar inte i sig att macOS MenuBarAgent ritar bilden på varje skärm.

## Manuell kontroll och gränser

Användaren har verifierat ikondöljningen i det första bygget och att indikatorn syns efter ikonändringen. Den samlade kontrollen av indikatorn medan andra ikoner är dolda följs upp separat. Layoutvyn visar medvetet alla ikoner tillfälligt; lämna den före ett sådant test.

De sex överhoppade testerna kräver uttrycklig hårdvaruvalidering (`DUOBAR_HARDWARE_VALIDATION=1`) och omfattar riktiga ljudenhetsbyten, volymändringar, ljuduppspelning och en AirPods-övergång. Dessa har inte körts. Äldre macOS-versioner och alla skärmkonfigurationer har inte provats fysiskt.

Appen är lokalt signerad och inte Apple-notariserad. macOS kan kräva ett nytt Hjälpmedelsgodkännande efter ett ombygge; LogiHides byggskript återställer inte användarens behörigheter.
