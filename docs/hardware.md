# Hardwaregrundlage und Schritt 1

## Vorgehen

1. TED-Register und Frequenzformel anhand des MOS-Datenblatts prüfen.
2. System- und Bildschirm-RAM freihalten, BASIC-SYS-Stub anlegen.
3. ACME-Build mit Speicherprüfungen und VICE-Start einrichten.
4. Build und Emulatorstart prüfen; Anzeige, Tastatur und Audio gesondert bewerten.

## TED

Quelle: [MOS TED 7360R0 Preliminary Data Sheet](https://www.pagetable.com/docs/ted/TED%207360R0%20Preliminary%20Data%20Sheet.pdf), PDF-Seiten 8–9 und 15–16.

`$FF0E/$FF12[1:0]` steuern Ton 1, `$FF0F/$FF10[1:0]` Ton 2 bzw. Rauschen. `$FF11` enthält Lautstärke (Bits 0–3, nutzbar 0–8), Ton 1 (Bit 4), Ton 2 (Bit 5), Rauschen (Bit 6) und Reload/Test (Bit 7). Bei gleichzeitig gesetzten Bits 5 und 6 hat Ton 2 Vorrang. Kombinationen verwenden daher Ton 1 plus Rauschen. `$FF12[7:2]` bleiben bei jeder Frequenzänderung aus dem aktuellen Registerwert erhalten.

Für den 10-Bit-Wert N gilt `f = K / (1024 - N)`: K = 110840,45 Hz (PAL), 111860,781 Hz (NTSC). Umrechnung: `N = 1024 - round(K / f)`, auf 0–1023 begrenzen. Die doppelte CPU-Geschwindigkeit außerhalb der Anzeige ändert diese Formel nicht. Schritt 2 berechnet getrennte Frequenzdaten und setzt 60 NTSC-Frame-Aufrufe auf 50 logische Ticks um.

## Speicher und KERNAL

Reserviert bleiben `$0000–$07FF` einschließlich Zero Page, Hardwarestack `$0100–$01FF` und Systemarbeitsbereichen. Standard-Textanzeige: Attribute `$0800–$0BFF`, Zeichen `$0C00–$0FFF` (je 1000 genutzte Bytes plus Reserve). PRG ab `$1001`, exklusives Ende höchstens `$4000`. Die Demo benutzt keine eigene Zero Page und schaltet ROMs und KERNAL-IRQ nicht ab. GETIN `$FFE4` liest den IRQ-befüllten Tastaturpuffer ohne auf eine Taste zu warten; CHROUT `$FFD2` übernimmt die Startanzeige. Aktionsentprellung wird erst mit dem vollständigen Menü umgesetzt.

Die abschließende Gegenprüfung der Systembereiche mit dem [Commodore-Handbuch](https://www.two-mag.com/cpc/ACME/_BONUS/8_BITS/COMMODORE%5BUSA%5D/1984_COMMODORE_PLUS-4%28264_range_prototype%29/Commodore_Plus4_Programmers_reference_guide%5BENG%5D.pdf) bleibt bis zur Auswertung des Downloads offen.

## Ergebnisse

- ACME 0.97: Build erfolgreich. PRG-Nutzlast 158 Bytes, `$1001–$109E`; Entry `$100D` / SYS 4109; Dateigröße 160 Bytes einschließlich Ladeadresse.
- Assembler prüft Programmende, Bildschirm-/Attributüberschneidung und vierstellige SYS-Adresse; ein zu großes Programm bricht den Build ab.
- VICE 3.10: Optionen über lokale `-help` geprüft. Startprotokoll bestätigt RAM-Injektion ab `$1001`, Programmstart und Autostart-Abschluss. CoreAudio öffnet die MacBook-Lautsprecher mit 48000 Hz.
- Sichtprüfung der Anzeige und Q-Rückkehr noch offen: Das native VICE-Fenster ist über die verfügbare UI-Steuerung nicht zugänglich. Keine Hörprüfung: Diese Startdemo erzeugt noch keinen Ton.
