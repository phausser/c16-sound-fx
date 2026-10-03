# C=16 Sound FX

105 TED-Soundeffekte für den Commodore 16 mit 16 KB RAM.

ACME, Make und VICE (`xplus4`) werden benötigt:

```sh
make
make run
```

Das PRG liegt unter `build/c16-sound-fx.prg`. `make run` startet einen
16-KB-C16 mit PAL und Sound. Toolpfade sind überschreibbar:
`make run ACME=/pfad/acme VICE=/pfad/xplus4`.

| Taste | Aktion |
|---|---|
| Cursor hoch/runter | Effekt auswählen |
| Cursor links/rechts | Seite wechseln |
| RETURN / SPACE | Auswahl starten/neustarten |
| 0–104, dann RETURN | Effekt direkt per ID starten |
| L | Loop ein/aus |
| S / RUN-STOP | Sound und Loop stoppen |
| H | Hilfe öffnen/schließen |
| Q | Zurück nach BASIC |
| P / N | PAL / NTSC wählen, Sound stoppen |

Für NTSC: `make run VICE_STANDARD=ntsc`, dann N drücken.
In der Hilfe kehrt auch RETURN/SPACE zum Katalog zurück.

Menüfreies Beispiel: `make run-example` (SPACE: Sprung, F: Schuss,
C: Sammeln, L: Motorloop, S: Stop, Q: BASIC).

[20 Spielvorbilder](docs/game-inspired.md) · [Mario und iOS](docs/mario-ios.md) · [Boulder Dash](docs/boulder-dash.md) · [Engine-API](docs/engine.md) · [Prüfstand und offene Aufgaben](docs/status.md)
