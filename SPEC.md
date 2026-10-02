# C16 Sound FX – Spezifikation

## Ziel und Umfang

Ein mit ACME assembliertes Programm für den Commodore 16 zeigt eine Liste mit genau 50 benannten Soundeffekten. Der Benutzer wählt einen Effekt und spielt ihn ab. Die Effekte sind für Spiele gedacht: kurze Geräusche, kurze Tonfolgen und wiederholbare Geräuschzyklen, keine Musikstücke. Diese Spezifikation definiert den Zielumfang; der tatsächliche Umsetzungs- und Prüfstand steht in `README.md`.

Zielgerät ist ein unveränderter C16 mit 16 KB RAM, zunächst PAL. C116 und Plus/4 sollen ohne zusätzliche Hardware funktionieren. NTSC wird über eine explizite Zeitbasis und passende Frequenzwerte unterstützt und separat geprüft.

## Hardware und Klanggestaltung

Der C16 besitzt keinen SID. Klangquelle ist der TED mit zwei Rechteck-Tonkanälen und einem Rauschgenerator. Rauschen teilt sich die Frequenzsteuerung mit dem zweiten Tonkanal; es ist keine unabhängig steuerbare dritte Stimme. Der erste Tonkanal kann Rauschen ergänzen. Bei gleichzeitig aktiviertem Ton 2 und Rauschen hat Ton 2 Vorrang. Kombinationseffekte verwenden deshalb Ton 1 plus Rauschen. Die Lautstärke ist für alle aktiven Quellen gemeinsam und wird im Bereich 0–8 verwendet.

Software erzeugt Hüllkurven, Frequenzgleiter, Tremolo, rhythmische Impulse und kurze Tonfolgen. Keine Samples, keine Erweiterungschips und keine kontinuierliche Begleitmusik. Namen beschreiben die beabsichtigte Spielaktion; etwa `vogelflug` ist eine stilisierte Klangdarstellung.

Relevante Register: `$FF0E` (Ton 1, Frequenz unten), `$FF0F` (Ton 2/Rauschen, Frequenz unten), `$FF10` (Ton 2, Frequenz oben), `$FF11` (Lautstärke und Quellensteuerung), `$FF12` (untere zwei Bits: Ton 1, Frequenz oben). Fremde Bits insbesondere in `$FF12` müssen erhalten bleiben, da sie auch die Anzeige beeinflussen. Registerbelegung und Frequenzberechnung werden vor der Implementierung anhand der Originaldokumentation geprüft.

## Bedienung und Anzeige

- 40 × 25 Zeichen, PETSCII-kompatible Namen ohne Umlaute.
- Drei Seiten: 24, 24 und 2 Einträge; ein Eintrag pro Zeile mit ID und Name.
- Inverse Kopfzeile mit `C=16 Sound FX`, Loopstatus `ON/OFF` vor `(H)elp` und rechts Seite `1/3` bis `3/3`; alle 24 Zeilen darunter sind Listeneinträgen vorbehalten, ohne Status- oder Fußzeile. Schwarzer Hintergrund und Rahmen, weiße Schrift.
- Anzeige nach zusammenhängenden Kategorien sortieren; vor jedem Namen `(KATEGORIE)` zeigen. Kategorien dürfen über Seitenwechsel weiterlaufen. Sortierung verändert die stabilen IDs nicht.
- Separate Hilfeseite mit allen Tastaturbefehlen: H öffnet/schließt sie; RETURN/SPACE kehrt zum Katalog zurück. Auswahl und laufende Wiedergabe bleiben erhalten. Navigation und ID-Eingabe sind auf der Hilfeseite gesperrt; Loop, Stop, Videostandardwechsel und Exit bleiben verfügbar.
- Cursor hoch/runter: Auswahl; links/rechts: Seite. Auswahlgrenzen werden begrenzt, kein unbeabsichtigtes Umspringen.
- RETURN oder SPACE: ausgewählten Effekt starten beziehungsweise von vorn starten.
- L: Wiederholung ein/aus. Jeder Effekt kann wiederholt werden; ausdrücklich loopbare Effekte haben einen gestalteten Zyklus. Bei Einzeleffekten liegt zwischen Wiederholungen eine kurze Pause.
- S oder RUN/STOP: Wiedergabe und Wiederholung sofort stoppen.
- Q: Programm verlassen und in BASIC zurückkehren.
- Blättern und Auswählen bleiben während der Wiedergabe möglich und verändern den laufenden Effekt erst beim erneuten Start.
- Tasten werden entprellt; Halten der Navigation darf mit kontrollierter Wiederholung arbeiten, Aktionskeys lösen nur einmal je Tastendruck aus.

## Effektkatalog

IDs sind zugleich stabile API-IDs (0–49). T = Ton, R = Rauschen, T+R = Kombination. Zeiten sind ungefähre Gestaltungsziele, keine bereits gemessenen Werte. „Loop“ kennzeichnet einen bewusst gestalteten wiederholbaren Zyklus; alle anderen Effekte sind kurze Einzeleffekte.

| ID | Name | Quelle | Zielzeit | Charakter / Einsatz | Loop |
|---:|---|---|---|---|:---:|
| 0 | jingle-win | T | 0,6 s | Drei aufsteigende Erfolgstöne | |
| 1 | jingle-lose | T | 0,6 s | Drei absteigende Niederlagetöne | |
| 2 | level-up | T | 0,4 s | Schnelle aufsteigende Tonfolge | |
| 3 | extra-life | T | 0,5 s | Helle doppelte Bestätigung | |
| 4 | checkpoint | T | 0,25 s | Zwei klare Quittungstöne | |
| 5 | coin-pickup | T | 0,12 s | Heller kurzer Sprung | |
| 6 | gem-pickup | T | 0,2 s | Funkelnde Zweitonfolge | |
| 7 | key-pickup | T | 0,2 s | Metallisch wirkender Doppelton | |
| 8 | power-up | T | 0,5 s | Aufwärtsgleiter mit Impulsen | |
| 9 | power-down | T | 0,5 s | Ausklingender Abwärtsgleiter | |
| 10 | menu-move | T | 0,04 s | Leiser Auswahlklick | |
| 11 | menu-select | T | 0,12 s | Bestätigender Doppelton | |
| 12 | menu-back | T | 0,12 s | Tiefer Rücksprung | |
| 13 | action-denied | T | 0,2 s | Zwei raue tiefe Töne | |
| 14 | pause-toggle | T | 0,15 s | Kurzer neutraler Signalton | |
| 15 | jump | T | 0,18 s | Steigender kurzer Gleiter | |
| 16 | double-jump | T | 0,25 s | Zwei steigende Impulse | |
| 17 | landing | R | 0,1 s | Gedämpfter Aufprall | |
| 18 | bounce | T | 0,2 s | Federnder Frequenzbogen | |
| 19 | fall | T | 0,6 s | Beschleunigender Abwärtsgleiter | |
| 20 | step-stone | R | 0,08 s | Trockener Schritt | |
| 21 | step-grass | R | 0,1 s | Weiches Rascheln | |
| 22 | walk-steps | R | 0,4 s | Gleichmäßige Schrittfolge | ja |
| 23 | swim-stroke | T+R | 0,4 s | Kurzer Blubberton und Wasserrauschen | ja |
| 24 | vogelflug | T | 0,5 s | Leichte Flügelschlag- und Zwitscherimpulse | ja |
| 25 | laser-shot | T | 0,15 s | Rascher hoher Abwärtsgleiter | |
| 26 | blaster-shot | T+R | 0,2 s | Tonimpuls mit rauem Ausklang | |
| 27 | machine-gun | R | 0,24 s | Drei kurze Schussimpulse | ja |
| 28 | explosion-small | R | 0,3 s | Kurzer abfallender Rauschstoß | |
| 29 | explosion-large | T+R | 0,8 s | Tiefer Stoß mit langem Rauschausklang | |
| 30 | ricochet | T | 0,2 s | Hoher scharf gekrümmter Gleiter | |
| 31 | sword-swing | R | 0,15 s | Schneller Luftstoß | |
| 32 | sword-hit | T+R | 0,2 s | Kurzer klingender Schlag | |
| 33 | player-hit | T+R | 0,25 s | Raues Schmerzsignal | |
| 34 | enemy-defeat | T+R | 0,4 s | Fallender Ton mit zerfallenden Impulsen | |
| 35 | shield-hit | T | 0,25 s | Zwei verstimmte kurze Töne | |
| 36 | door-open | T+R | 0,4 s | Steigendes Knarren mit Rauschanteil | |
| 37 | door-close | R | 0,2 s | Kurzes Zuschlagen | |
| 38 | switch-click | R | 0,04 s | Sehr kurzer trockener Klick | |
| 39 | chest-open | T | 0,35 s | Kurze helle Entdeckungsfolge | |
| 40 | teleport | T+R | 0,6 s | Schneller Wechsel aus Gleiten und Rauschen | |
| 41 | engine-idle | T | 0,4 s | Tiefer pulsierender Motorzyklus | ja |
| 42 | engine-boost | T+R | 0,6 s | Steigende Drehzahl mit Rauschschub | |
| 43 | alarm | T | 0,5 s | Alternierende Warnimpulse | ja |
| 44 | timer-tick | T | 0,05 s | Kurzer trockener Zeitimpuls | |
| 45 | countdown-end | T | 0,3 s | Dringlicher kurzer Mehrfachton | |
| 46 | water-splash | R | 0,35 s | Heller Stoß mit weichem Auslauf | |
| 47 | fire-crackle | R | 0,6 s | Unregelmäßige leise Knisterimpulse | ja |
| 48 | wind-gust | R | 0,8 s | An- und abschwellendes Rauschen | ja |
| 49 | electric-zap | T+R | 0,25 s | Schnelles Flattern und Rauschabschluss | |

## Architektur und Integration in Spiele

Die Wiedergabe wird vom Menü getrennt. Eine datengetriebene Engine spielt genau einen logischen Effekt gleichzeitig; ein neuer Start ersetzt den vorherigen Effekt. Innerhalb eines Effekts dürfen beide Tonkanäle und Rauschen verwendet werden. Gleichzeitiges Mischen mehrerer unabhängiger Effekte und Musik ist nicht Bestandteil dieser Version.

Öffentliche Routinen:

- `sfx_init`: Zustand initialisieren, Sound ausschalten, gemeinsam genutzte Registerbits sichern.
- `sfx_play`: A = ID 0–49; startet den Effekt ohne Warteschleife. Ungültige IDs liefern Carry gesetzt und lassen den bisherigen Zustand bestehen; gültige IDs liefern Carry gelöscht.
- `sfx_tick`: exakt einmal je Video-Frame vom aufrufenden Programm aufrufen; führt höchstens einen fälligen Effektschritt aus, ohne zu warten.
- `sfx_stop`: stoppt alle von der Engine verwendeten Klangquellen und verwirft Wiederholung.
- `sfx_set_loop`: A = 0/1; steuert Wiederholung. Ausschalten lässt den aktuellen Durchlauf zu Ende spielen.
- `sfx_shutdown`: beendet Wiedergabe und gibt gesicherte Ressourcen zurück.

Registerzerstörung, Zero-Page-Bedarf, RAM-Bedarf und Laufzeit werden dokumentiert. Die Engine installiert selbst keinen IRQ und ruft keine KERNAL-Routinen auf. Das Demo übernimmt Frame-Takt und Tastatur. Kein Effekt verwendet blockierende Verzögerungsschleifen. Der Aufrufer besitzt die Soundregister während der Nutzung; das Teilen von `$FF12` mit Videocode bleibt möglich, indem dessen aktuelle übrige Bits erhalten werden.

Effektdaten bestehen aus begrenzten Schritten mit Dauer, zwei 10-Bit-Frequenzwerten, Quellenmaske und gemeinsamer Lautstärke. Ein Endmarker sowie optionaler Loop-Einstieg beschreiben den Ablauf. Frequenzgleiter und Hüllkurven werden zunächst als kompakte vorberechnete Schritte gespeichert. Höchstens ein Schrittwechsel je Tick; alle Schritte dauern mindestens einen logischen Tick. Ein Software-Zufallszustand erzeugt reproduzierbare Knistervariationen ohne fremde Speicherzugriffe.

PAL ist die Referenz mit 50 logischen Ticks/s. Unter NTSC läuft die Engine weiterhin einmal je Frame; ein Akkumulator übersetzt 60 Frame-Aufrufe in 50 logische Ticks. Frequenzwerte berücksichtigen separat den jeweiligen TED-Takt. Der Videostandard wird beim Init explizit übergeben; die Demo ermittelt ihn oder bietet eine dokumentierte Auswahl.

## Dateien, Build und Speicher

Geplant: `src/main.asm`, `src/menu.asm`, `src/sfx_engine.asm`, `src/sfx_data.asm`, `src/ted.inc`, `examples/game_integration.asm`, `Makefile`, `README.md` und `build/c16-sound-fx.prg`.

`make` baut das PRG mit ACME. `make run` baut es bei Bedarf und startet es anschließend automatisch in VICE (`xplus4`) mit aktiviertem Sound, C16-Modell, 16 KB RAM und PAL als Standard. Der BASIC-Startstub wird per Autostart ausgeführt. Die installierten Programme wurden unter `/opt/homebrew/bin/acme` und `/opt/homebrew/bin/xplus4` gefunden. Das Makefile verwendet standardmäßig die Befehle aus dem PATH und erlaubt Overrides über `ACME` und `VICE`. Die passenden VICE-Optionen werden bei der Umsetzung anhand der installierten Version geprüft.

ACME erzeugt ein CBM-PRG mit BASIC-SYS-Startstub ab `$1001`. Die tatsächliche SYS-Adresse wird aus dem Entry-Label abgeleitet. Programm, Daten, Bildschirm, Arbeitszustand und Stack müssen zusammen in den C16-RAM passen; kein Zugriff auf vermeintliches RAM oberhalb `$3FFF`. Ein Build-Check prüft das obere Programmende und die reservierten Bereiche. Bildschirm- und KERNAL-Arbeitsbereiche werden vor der endgültigen Speicheraufteilung geprüft. Kein dauerhaftes Abschalten der ROMs ist vorgesehen.

## Abnahmekriterien

1. Reproduzierbarer ACME-Build liefert ein auf dem 16-KB-C16 startbares PRG.
   `make run` baut und startet die Demo in der installierten VICE-Version; die Effekte sind über deren Audioausgabe hörbar.
2. Genau 50 stabile IDs und eindeutige Namen; alle Einträge sind erreichbar und spielbar.
3. Ton, Rauschen, kombinierte Effekte und kurze Tonfolgen sind vertreten.
4. Alle Einzeleffekte enden selbständig und hinterlassen keine eingeschaltete Klangquelle.
5. Wiederholung funktioniert bis zum Stop; gestaltete Loops haben keinen unbeabsichtigten stummen Frame am Zyklusübergang. Physikalisch völlig klickfreie Übergänge sind kein pauschales Versprechen.
6. Navigation, Neustart, Stop und Exit funktionieren während der Wiedergabe; Stop wirkt spätestens im nächsten Frame.
7. Keine Bildbeschädigung durch Soundregisterzugriffe, keine Speicherüberschreitung.
8. Engine ist unabhängig vom Menü in ein kleines Beispielspiel integrierbar.
9. Emulatorprüfung mit 16 KB RAM und Hörprüfung aller 50 Effekte; NTSC separat. Prüfung auf echter Hardware ist wünschenswert und wird nur bei tatsächlicher Durchführung als bestanden ausgewiesen.
10. Gemessene RAM-Nutzung und maximale Tick-Laufzeit werden im README festgehalten. Ziel für `sfx_tick`: höchstens 1.000 CPU-Zyklen pro Aufruf, ohne Menü und IRQ-Verwaltung; am langsameren CPU-Takt bewerten.

## Technische Referenzen

- MOS Technology: [TED 7360R0 Preliminary Data Sheet](https://www.pagetable.com/docs/ted/TED%207360R0%20Preliminary%20Data%20Sheet.pdf).
- Commodore: [Plus/4 Programmer’s Reference Guide](https://www.two-mag.com/cpc/ACME/_BONUS/8_BITS/COMMODORE%5BUSA%5D/1984_COMMODORE_PLUS-4%28264_range_prototype%29/Commodore_Plus4_Programmers_reference_guide%5BENG%5D.pdf).

Die Originalquellen dienen bei der Umsetzung als Grundlage für Register, Speicherbelegung und Timing; die Referenzlinks wurden für diese Planung recherchiert.
