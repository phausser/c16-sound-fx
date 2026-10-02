# Soundengine: API und Prüfergebnisse

## Einbindung

`src/sfx_engine.asm` und anschließend `src/sfx_data.asm` in ein ACME-Programm aufnehmen; zuvor die Konstanten aus `src/ted.inc` einbinden. Code und Zustand müssen in beschreibbarem RAM liegen. Die Engine verwendet einen selbstmodifizierten absoluten Datenzugriff und benötigt keine Zero Page. Sie installiert keinen IRQ, wartet nicht und ruft keine KERNAL-Routine auf. Der Aufrufer besitzt die Soundregister und serialisiert API-Aufrufe; insbesondere dürfen Menü und IRQ die Engine nicht gleichzeitig betreten.

Einmal `sfx_init` vor der ersten Nutzung, dann `sfx_tick` exakt einmal pro Video-Frame aufrufen. Vor einer erneuten Initialisierung erst `sfx_shutdown` aufrufen, damit die ursprünglichen Registerwerte erhalten bleiben. Die Demo erkennt Frame-Grenzen über das steigende Rasterbit 8 in `$FF1C`; diese Abfrage gehört zum Demo, nicht zur Engine. P/N wählt explizit die Zeitbasis und muss zum Videostandard des Emulators passen.

| Routine | Eingabe und Verhalten |
|---|---|
| `sfx_init` | A=0 PAL, A=1 NTSC; sichert Register und schaltet Sound aus; andere Werte: C=1, unverändert |
| `sfx_play` | A=ID 0–49; ersetzt Wiedergabe und setzt sofort den ersten Schritt; C=0; andere IDs: C=1, unverändert |
| `sfx_tick` | Ein Aufruf pro Frame; höchstens ein hörbarer Schrittwechsel; Carry ohne Bedeutung |
| `sfx_stop` | Sound aus, Wiedergabe und Wiederholung verworfen |
| `sfx_set_loop` | A=0/1, C=0; Abschalten beendet den aktuellen Durchlauf regulär; andere Werte: C=1, unverändert |
| `sfx_shutdown` | Stoppt, stellt gesicherte Frequenzen und Soundsteuerung wieder her; aktuelle fremde Registerbits bleiben erhalten |

Alle Aufrufe dürfen A/X/Y und Statusflags zerstören. Der Aufrufer hält den Dezimalmodus ausgeschaltet (`CLD`). Die Routinen lassen Stack und Interruptfreigabe unverändert. Maximal 6 Stackbytes einschließlich der Rücksprungadresse des API-Aufrufs, ohne einen unterbrechenden IRQ. Die Engine schreibt nur `$FF0E–$FF12`, eigene Zustandsbytes und zwei Operandbytes. Bei `$FF12` bleiben Bits 2–7 aus dem aktuellen Wert erhalten, bei `$FF10` Bits 2–7 ebenfalls. Shutdown darf zuvor aktive Soundquellen des Aufrufers wiederherstellen.

## Daten und Wiederholung

Ein Schritt hat sechs Bytes: Dauer in logischen Ticks (1–255), Frequenz 1 low/high, Frequenz 2 low/high, Quellenmaske inklusive Lautstärke. Ein einzelnes Nullbyte anstelle der Dauer beendet einen Ablauf. Frequenzen sind 10 Bit, Lautstärke 0–8; Ton 2 zusammen mit Rauschen und Reload/Test werden beim Build abgewiesen. Die Daten werden als vertrauenswürdige, vom Build geprüfte Streams eingebunden.

Jeder ID-Eintrag enthält zwei 16-Bit-Adressen: Start und Wiederholungseinstieg. Der Einstieg kann einen einmaligen Vorspann überspringen. `sfx_flags` enthält Bit 0 für gestaltete Loops ohne eingefügten stummen Tick und Bit 1 für reproduzierbare Rauschvariation. Einzeleffekte wiederholen mit zehn Ticks Pause. Alle aktuellen Katalogeinträge wiederholen ab Start. `fire-crackle` trägt beide Bits; sein 8-Bit-Galois-LFSR startet bei jedem gültigen Play mit `$A5`, aktualisiert sich pro Schritt und verändert nur die unteren vier Rauschfrequenzbits. Der Zufallszustand bleibt über Loopgrenzen erhalten. Die Loop-Präferenz bleibt beim Neustart und natürlichen Ende erhalten; Stop verwirft sie. Abschalten während einer Wiederholungspause verhindert den nächsten Start.

PAL: jeder Frame ist ein logischer Tick. NTSC: ein Akkumulator addiert 50 je Frame und erzeugt bei mindestens 60 einen Tick; pro 60 Aufrufen entstehen 50 logische Ticks. Die Phase läuft unabhängig von der Wiedergabe weiter. Frequenzdaten liegen separat für PAL und NTSC vor und werden mit gerundeten Konstanten 110840 bzw. 111861 aus der dokumentierten TED-Formel erzeugt.

Alle 50 stabilen IDs haben eigene, nicht leere Abläufe; Namen, Dauern und Loopflags werden gegen `SPEC.md` geprüft. Der Katalog enthält 208 Schritte, beide Taktvarianten und 50 PETSCII-Namen samt Zeigertabelle. Details: [effects.md](effects.md).

## Prüfungen und Grenzen

`make test` führt mit py65 1.2.0 den wirklich assemblierten 6502-Code aus. Geprüft: alle 50 gültigen Slots, ungültige IDs/Init-/Loop-Werte ohne Zustandsänderung, Neustart, exakte PAL-/NTSC-Dauern, Stop, Loop-Abschaltung, 200-ms-Pause, unterbrechungsfreie Alarmzyklen, separater Wiederholungseinstieg, Daten über eine Seitengrenze, Schreibbereiche und aktuelle fremde Registerbits auch beim Shutdown.

Gemessen am aktuellen Build: maximal **332 CPU-Zyklen pro getesteten Tick**, inklusive API-RTS; 501 Bytes Enginecode (einschließlich zwei veränderlicher Operandbytes), 20 Bytes zusätzlicher Zustand, 3748 Bytes Katalogdaten, Tabellen und Namen. Engine samt Daten: 4269 Bytes; Zero Page: 0 Bytes. Die Katalogdemo belegt 6543 Bytes ab `$1001` bis `$298F`; PRG inklusive Ladeadresse: 6545 Bytes. Die Zyklusmessung zählt CPU-Instruktionszyklen, keine TED-DMA-Verzögerungen oder IRQ-Arbeit; sie ist keine Hardware-Wallclockmessung.

`make test-vice` prüft VICE 3.10 mit C16, 16 KB RAM, jeweils PAL und NTSC: Autostart, Bildschirmtext im echten Bildschirm-RAM, alle 50 Starts per KERNAL-Tastaturpuffer, automatisches Ende, acht Loops mit Stop, numerische ID-Eingabe und Erhaltung der Videobits und Q-Rückkehr in den BASIC-ROM-Code bei `$A7CF`. Der Test benutzt den Dummy-Audiotreiber und ersetzt keine Hörprüfung. Monitorbefehle folgen dem [VICE-Monitorhandbuch](https://vice-emu.sourceforge.io/vice_12.html). Logs und Registeraufnahmen liegen unter `build/`.

Offen bleiben Hörprüfung und Klangabstimmung, echte Hardware sowie die manuelle Bedienprüfung mit gehaltenen Host-Tasten. Die Demo deaktiviert die KERNAL-Wiederholung während der Nutzung und steuert Cursortastenwiederholung selbst. CPU-Tests prüfen die Wiederholungsintervalle auf PAL/NTSC; VICE prüft Kategorienseiten, separate Hilfe und Navigation während Loops. Katalog und Hilfe sind per Screenshot visuell geprüft.

Die Tick-Zykluszahl hängt auch von der Linkadresse ab (Seitenübertritte bei
6502-Zweigen und Tabellenzugriffen). Beim aktuellen Kategorie-/Hilfemenü liegt der höchste getestete Wert
bei 332 Zyklen (vorheriger Menüstand: 342); die Engine selbst ist unverändert.
