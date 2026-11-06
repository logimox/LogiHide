# Verifiering av LogiHide 0.1.1

Kontrollerat lokalt den 6 november 2026 på macOS 27.2, med Xcode 27.0 och Swift 6.4.

## Bekräftad riktig körning

LogiHide körs från `/Applications/LogiHide.app`. Användaren har uttryckligen bekräftat att indikatorn nu stannar kvar samtidigt som övriga ikoner döljs.

macOS MenuBarAgent exponerar dessutom LogiHides verkliga menyknapp med värdet `9 hidden items` medan döljningen är aktiv. Statuspanelen öppnades från inställningarna och visade levande nätverks-, batteri-, volym- och ljudenhetsdata. Hjälpprocessen körs inuti den installerade appens `Contents/Helpers`.

Samma bygge startat från projektets byggmapp fick sin egen indikator dold. Flytten till Program löste detta. Begränsningen är dokumenterad i [Thaws vanliga problem](https://www.getthaw.app/docs/thaw/frequent-issues#apps-running-outside-applications) och [upstream-felet med korrigerad orsaksanalys](https://github.com/thaw-app/Thaw/issues/1374#issuecomment-6315243451). Installationsanvisningarna och byggskriptet säger därför uttryckligen att appen ska köras från `/Applications`.

## Godkända automatiska kontroller

- Release-bygge för arm64 och x86_64 genom `Scripts/build-logihide.sh`.
- HolzBarCore: 1 478 tester, utan fel.
- HolzBarMacOS27Core: 258 tester, utan fel.
- SharedCodeSigning: tre tester, utan fel.
- DuoStatusKit: 331 tester, varav sex uttryckligen överhoppade hårdvarutester, utan fel.
- 17 testfall för signaturkontrollen, samtliga med väntat resultat. De nya fallen verifierar att den inbäddade hjälpprocessen är tillåten endast på rätt plats, utan entitlements och med hardened runtime.
- Hjälpprocessens riktiga pipe-protokoll besvarade ett invalidate-kommando och avslutades med kod 0 när indata stängdes.
- Appen och båda inbäddade komponenterna klarar signaturkontrollen och `codesign --verify --deep --strict`.
- Båda licenstexterna och DuoStatusKit:s språkresurser ingår i appen.
- Installationsskriptet klarar `bash -n`.

## Gränser

De sex överhoppade testerna kräver uttrycklig hårdvaruvalidering (`DUOBAR_HARDWARE_VALIDATION=1`) och omfattar riktiga ljudenhetsbyten, volymändringar, ljuduppspelning och en AirPods-övergång. Dessa har inte körts. Äldre macOS-versioner och alla skärmkonfigurationer har inte provats fysiskt.

Appen är lokalt signerad och inte Apple-notariserad. macOS kan kräva ett nytt Hjälpmedelsgodkännande efter ett ombygge; LogiHides bygg- och installationsskript återställer inte användarens behörigheter. Sparade inställningar behölls vid installationen i Program.
