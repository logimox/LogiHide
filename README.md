# LogiHide

En menyapp för macOS som samlar batteri, nätverk och ljud i en kompakt indikator och kan dölja menyfältsikoner.

LogiHide är en modifierad fork av [holzBar](https://github.com/holzcloud/holzBar), med statusindikatorn och systemkontrollerna från [DuoBar](https://github.com/Mikeli7666/DuoBar). Grundfunktionerna för menyhantering kommer från holzBar och dess ursprungliga bas [Ice](https://github.com/jordanbaird/Ice).

## Installation

Flytta **LogiHide.app till `/Applications` (Program)** och starta den därifrån. På macOS 27 kan en app som körs från exempelvis en byggmapp få sin egen menyikon dold medan döljningen är aktiv. Detta är en [dokumenterad macOS-begränsning](https://www.getthaw.app/docs/thaw/frequent-issues#apps-running-outside-applications). Starta en kopia åt gången och behåll den installerade kopian som din vanliga app.

## Användning

- **Klicka** på indikatorn för batteri, nätverk, volym och ljudenheter.
- **Skiftklicka** för att visa eller dölja ikoner. Samma åtgärd finns i statuspanelen.
- **Högerklicka** för menyhantering och inställningar. Innan behörigheterna är klara öppnas behörighetsfönstret.
- Öppna **Menyfältslayout / Menu Bar Layout** för att välja vilka ikoner som ska döljas. holzBars separata Shelf, profiler, kortkommandon och automationsregler finns kvar.
- **Systemstatus / System Status** i inställningarna styr indikatorns storlek, batteriprocent, färger, animeringar och öppning vid hovring.
- Alternativklick behåller holzBars åtgärd för den permanent dolda sektionen, när den är aktiverad.

Indikatorn visar batterinivå på bärbara Macar och en adaptiv belastningsring på stationära. Panelen har nätverkshastighet, ljudreglage och val av ljudingång/utgång. Svenska och engelska stöds; vissa mindre använda statustexter faller tillbaka på engelska. Ytterligare språk följer med från projekten.

## Behörigheter

Systemstatus går att öppna utan Hjälpmedel. För att dölja och flytta andra appars ikoner behöver du tillåta LogiHide under **Systeminställningar → Integritet och säkerhet → Hjälpmedel** och fortsätta i appens behörighetsfönster. Skärminspelning är valfri och används för bilder av menyikoner. Wi-Fi-namn kan kräva platstjänster. Övriga frivilliga moduler frågar efter sina respektive behörigheter när de aktiveras.

Kör en menyhanterare åt gången. LogiHide känner igen holzBar, Ice, Thaw, Bartender och Hidden Bar som möjliga konflikter och frågar innan de avslutas.

Appen har egen identitet (`com.logimox.LogiHide`), egna inställningar och en egen mapp i Application Support. Den skriver inte i holzBars eller DuoBars inställningar. Den ärver holzBars engångsimport av äldre Ice-inställningar. URL-kommandon använder `logihide://`.

## Bygg och testa

Kräver macOS 14 eller senare för appen och Xcode 27 med macOS 27 SDK för att bygga hela projektet.

```sh
./Scripts/build-logihide.sh
./Scripts/test-logihide.sh
# Avsluta LogiHide före installation:
./Scripts/install-logihide.sh
```

Öppna alternativt `holzBar.xcodeproj` och välj schemat **LogiHide**. Projektfilen och interna holzBar-symboler behåller sina namn för att göra framtida uppdateringar från upstream enklare. Produkten heter `LogiHide.app` och byggs till `build/Build/Products/Release/`.

Byggskriptet signerar lokalt, utan ett Apple-utvecklarkonto. Det installerar inte appen och återställer inga behörigheter. Bygget är inte Apple-notariserat. Äldre upstream-skript och distributionsfiler i repot avser holzBar; använd skripten ovan för LogiHide.

På macOS 27 körs själva döljningen i den inbäddade bakgrundsappen `LogiHideConcealer.app`. Den har inga menyikoner eller extra behörigheter och kommunicerar bara med huvudappen genom privata standardströmmar. När huvudappen avslutas stängs kanalen, hjälpprocessen släpper sina döljningsanspråk och avslutas. Detta håller indikatorn skild från processen som macOS använder för döljningen.

Under Allmänt finns även separata knappar för att öppna systemstatus samt visa och dölja ikoner. Menyfältslayout visar tillfälligt alla ikoner medan vyn är öppen.

`Vendor/DuoStatusKit` innehåller en lokal kopia av DuoBars statuskod och tester, med dess ursprungliga Swift 5-språkläge. Huvudappen behåller holzBars Swift 6-inställningar. Inga externa paket hämtas.

## Licens och ursprung

Den sammanslagna appen distribueras under **GNU GPL v3.0**. Se [LICENSE](LICENSE) och [NOTICE](NOTICE). Om du distribuerar appen ska motsvarande källkod göras tillgänglig enligt GPL.

- holzBar: GPL v3.0, bas `3129512c6f22cf572fadab7cd547dab3aeb3fd2e`.
- DuoBar: MIT, Copyright (c) 2026 Mike Li, bas `fc348a53a25855b7c9433583b4beae4eb256feeb`.
- Ursprunglig menyhantering: Ice av Jordan Baird. Ytterligare krediter finns i appens Om-vy.

DuoBars fullständiga MIT-text finns i [Vendor/DuoStatusKit/LICENSE](Vendor/DuoStatusKit/LICENSE). Både MIT och GPL finns också att läsa offline i appens licensvy. LogiHide ändrades av logimox den 6 november 2026 och är ett fristående projekt utan koppling till originalens utvecklare.

Verifiering för denna version finns i [VALIDATION.md](VALIDATION.md).
