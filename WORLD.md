# Welt-Regeln

Pixel Hop ist eine 3D-Welt aus Blöcken mit Pixel-Texturen. Diese Regeln gelten für alles, was neu dazukommt.

## Maße

- **1 Block = 1 × 1 × 1** (RealityKit-Einheit, gedacht als Meter).
- **Block-Texturen: 16 × 16 Pixel** pro Fläche, ein Texel ist also 1/16 Block.
- **Voxel-Modelle: Würfel mit 0,1 Kantenlänge**, ein Modell über eine Kachel ist also 10 × 10 Voxel groß.
- Achsen: x nach Osten, y nach oben, z nach Süden. Norden ist auf dem Bildschirm oben.
- Kachel (Spalte, Zeile) belegt x ∈ [Spalte, Spalte + 1], z ∈ [Zeile, Zeile + 1]. Spalten und Zeilen dürfen negativ sein, die Welt ist in alle Richtungen unendlich.

## Karte

- Jede Kachel hat genau ein Zeichen: `WorldMap.tile(Spalte, Zeile)`.
- **Heimatinsel**: `WorldMap.home` ist die von Hand gebaute Hafenstadt (48 × 32). Ihre linke obere Ecke ist Kachel (0, 0). Ein Kanal umgibt sie, und Brücken führen nach Westen, Osten und Süden aufs Festland.
- **Alles andere** berechnet `WorldGen.tile` aus den Regeln unten. Das Ergebnis ist für jede Kachel immer gleich.
- Jedes Zeichen ist ein **Block** (`Block` in `PixelHop/Textures.swift`) mit Textur oben, Textur seitlich, Höhe der Oberkante und der Angabe, ob man durchlaufen kann.
- Jedes Zeichen kann zusätzlich ein **Requisit** tragen (`Models.props`). Das ist ein Voxel-Modell mit einer **Grundfläche** in Kacheln. Eine 3 × 3-Grundfläche schreibt man, indem man das Zeichen 3 × 3-mal in die Karte setzt. Gleiche Zeichen nebeneinander ergeben mehrere Häuser, aufgeteilt von links oben aus. Das Modell steht mittig auf der Grundfläche, auf der Höhe seines Blocks.

| Zeichen | Block | Höhe | Requisit (Grundfläche) | Begehbar |
|---|---|---|---|---|
| `,` | Kopfsteinpflaster, Kaimauer als Seite | 0 | – | ja |
| `.` | Gras | 0 | – | ja |
| `*` | Gras mit Blumen | 0 | – | ja |
| `=` | Sandweg | 0 | – | ja |
| `:` | Strand | −0,3 | – | ja |
| `#` | Holzsteg | 0 | – | ja |
| `~` | Wasser | −0,8 | – | nein |
| `H` | Pflaster | 0 | Haus, Sandstein mit rotem Dach (3 × 3) | nein |
| `G` | Pflaster | 0 | Haus, rot mit orangem Dach (3 × 3) | nein |
| `L` | Pflaster | 0 | Leuchtturm (2 × 2) | nein |
| `P` | Pflaster | 0 | Laterne | nein |
| `B` | Pflaster | 0 | Bank | nein |
| `F` | Pflaster | 0 | Blumenbusch im Topf | nein |
| `Y` | Strand | −0,3 | Palme | nein |
| `T` | Gras | 0 | Baum | nein |
| `R` | Gras | 0 | Stein | nein |
| `C` `c` `d` `s` | Pflaster, Gras, Steg, Strand | je nach Block | Münze | ja |
| `@` | Pflaster | 0 | Startpunkt von Hopper | ja |

- Ist eine Nachbarkachel niedriger, bekommt der Block dort eine Seitenwand. Weil das Wasser tiefer liegt, entstehen am Wasser 0,8 hohe Kaimauern.
- Hopper und Münzen stehen immer auf der Höhe des Blocks unter ihnen.

## Unendliche Welt (`WorldGen.swift`)

Zufall gibt es nur über `Hash.value` (FNV-Hash) mit einem festen Seed pro Regel. Rauschen ist Wert-Rauschen mit zwei Oktaven (`fbm`). Die Regeln gelten der Reihe nach, die erste passende gewinnt:

1. **Heimat-Ring**: Bis 3 Kacheln um die Heimatinsel ist Wiese, damit die Brücken frei ankommen.
2. **Höhe**: Höhen-Rauschen mit Maßstab 38. Nahe der Heimat gibt es einen Bonus, deshalb ist dort Land. Unter −0,15 ist Wasser `~`, unter −0,08 Strand `:` mit 4 % Palmen `Y` und 1 % Münzen `s`.
3. **Dörfer**: Die Welt ist in Zellen von 6 × 6 Kacheln geteilt. Eine Zelle ist Dorf, wenn in ihrer Mitte das Dorf-Rauschen (Maßstab 70) über 0,22 liegt, dort Land ist und sie mehr als 10 Kacheln von der Heimat entfernt liegt.
   - Die erste Zeile und Spalte jeder Zelle ist Straße `,`.
   - 70 % der Zellen haben ein Haus `H`/`G` (3 × 3, ab Position 1,1), daneben eine Laterne, manchmal einen Busch und eine Bank. Die anderen Zellen sind kleine Plätze mit Bäumen, Büschen und einer Laterne.
   - Ein Haus gibt es nur, wenn alle 9 Kacheln Land sind.
4. **Feldwege** `=`: wo der Betrag des Weg-Rauschens (Maßstab 30) unter 0,035 liegt.
5. **Wald**: Wo das Wald-Rauschen (Maßstab 24) über 0,25 liegt, stehen auf 38 % der Kacheln Bäume.
6. **Wiese**: sonst 2,5 % Bäume, 1,5 % Steine, 7 % Blumen.
7. **Münzen**: 0,8 % auf Wiese und Wegen, 1–1,5 % auf Dorfstraßen.

Ein neues Gelände oder ein neues Requisit braucht ein neues Zeichen in `WorldGen.tile`, einen Block in `Textures.swift` und gegebenenfalls ein Requisit in `Models.props`.

## Laden in Stücken (`Chunks.swift`)

- Die Welt wird in **Chunks von 16 × 16 Kacheln** geladen. Geladen ist das Rechteck um Hopper: 28 Kacheln nach links und rechts, 20 nach Norden, 14 nach Süden. Was einen Chunk weiter draußen liegt, wird entladen.
- Pro Bild werden höchstens 2 neue Chunks gebaut, die nächsten zuerst. Beim Start wird alles Sichtbare auf einmal gebaut.
- Jeder Chunk hat ein eigenes Gelände-Mesh und Kopien der Requisiten und Münzen. Jedes Requisiten-Modell wird nur einmal als Mesh gebaut.
- Requisiten mit mehreren Kacheln gehören zum Chunk ihrer linken oberen Kachel.
- `WorldMap` merkt sich die berechneten Zeichen pro Chunk.
- Eingesammelte Münzen merkt sich das Spiel bis zum Neustart, damit sie beim erneuten Laden nicht wieder auftauchen.

## Farben und Texturen

- Alle Farben kommen aus `Palette.colors`. Neue Farben kommen dort mit einem Buchstaben dazu, zum Beispiel `a`/`f` für Sandstein, `q`/`j`/`v` für Türkis, `x` für hellen Stein und `z` für Terrakotta.
- Texturen sind ASCII mit 16 × 16 Zeichen in `Textures.all`. Zeile 0 ist bei Oberseiten Norden und bei Seitenwänden oben. Bei niedrigen Wänden sieht man nur den oberen Teil, deshalb kommt die Kante (Grasnarbe, Deckstein) in die obersten Zeilen.
- Alles landet in einer einzigen Textur, dem **Atlas** (`Atlas.swift`), mit Pixel-genauer Abtastung ohne Weichzeichnen.
- **Licht ist eingebacken**: Jede Würfelseite hat eine feste Helligkeit (`Face.brightness`). Oben 100 %, Süden 86 %, Westen 78 %, Osten 68 %, Norden 60 %, unten 50 %. Das Licht kommt also von oben links vorne. Die Materialien sind unbeleuchtet (`UnlitMaterial`), damit die Palette-Farben genau so erscheinen.

## Voxel-Modelle

- `VoxelModel` in `PixelHop/VoxelModel.swift`, die Modelle selbst stehen in `PixelHop/Models.swift`.
- Modelle werden aus Formen gebaut: `box` (Quader), `ball` (Ellipsoid) und `cylinder` (Säule, Radius pro Höhe), je mit einer Palette-Farbe oder einer Farb-Regel pro Voxel. Gibt die Farb-Regel `nil` zurück, bleibt das Voxel leer. Für Zufallsmuster gibt es `VoxelModel.noise`, das ist für jede Position immer gleich.
- Der Drehpunkt liegt unten in der Mitte. Ein Modell darf über seine Grundfläche hinausragen, etwa Palmwedel oder Dachüberstände.
- Gebäude schauen mit Tür und Fenstern nach Süden zur Kamera.
- Nur sichtbare Außenflächen werden gezeichnet. Gleichfarbige, aneinanderliegende Flächen werden zu großen Rechtecken zusammengefasst (Greedy Meshing), damit auch viele Häuser flüssig laufen.

## Hopper

- Hopper ist ein weißer Hase (`Models.hopper`), 9 × 15 × 10 Voxel groß, und schaut im Modell nach Süden.
- Die Hitbox ist 0,6 × 0,6 Blöcke. Läuft Hopper schräg vor eine Lücke, rutscht er automatisch in die Gasse.
- Beim Laufen hüpft er (Sinus, 0,25 hoch) und dreht sich weich in die Laufrichtung. Sein Schatten bleibt am Boden.
- Er läuft 3,2 Blöcke pro Sekunde.

## Bewohner

- Bewohner sind Tiere aus Voxeln (`Animals.swift`), beschrieben als Arten in `Species.swift`:

| Kürzel | Art | Namen | schenkt eine Münze |
|---|---|---|---|
| `k` | Katze | Mimi, Karl, Luna | ja |
| `h` | Hund | Bello, Bruno, Rex | ja |
| `c` | Huhn | Hilde, Gacki, Berta | nein |
| `d` | Ente | Emma, Quaki, Paula | nein |
| `f` | Fuchs | Fred, Flinki, Rosa | ja |
| `q` | Frosch | Fritz, Quabbel, Kiki | nein |

- **Wo sie wohnen** (`Residents.swift`): Auf der Heimatinsel gibt es 8 feste Bewohner (`Residents.home`), einer davon, der Hund, steht direkt neben dem Start bei (23, 18). Draußen entscheidet der Hash pro begehbarer Kachel:
  - auf Pflaster 1,2 %: Katze, Hund oder Huhn
  - auf Wiese, Blumen und Wegen 0,4 %: Fuchs, Frosch, Huhn oder Hund
  - am Strand 1 %: Ente oder Frosch
  - Name und erster Satz kommen ebenfalls aus dem Hash.
- Bewohner gehören zu dem Chunk, in dem sie wohnen, und verschwinden mit ihm.
- **Verhalten**:
  - Sie laufen in einem Umkreis von 3 Kacheln um ihr Zuhause herum, warten zwischendurch 1–3 Sekunden und weichen blockierten Kacheln aus.
  - Beim Laufen hüpfen sie ein wenig. Ist Hopper näher als 1,6 Kacheln, bleiben sie stehen und schauen ihn an.
- **Reden**:
  - Ist ein Bewohner in der Nähe, erscheint unten rechts die Sprechblase.
  - Tippt man darauf, hüpft der Bewohner vor Freude, und unten erscheint ein Textfeld mit Name und Satz. Bei jedem Gespräch kommt der nächste Satz.
  - Katzen, Hunde und Füchse schenken beim ersten Gespräch eine Münze.
  - Das Textfeld schließt sich beim Antippen, nach 6 Sekunden oder wenn Hopper weggeht.
- Alle Texte sind kurz, freundlich und auf Deutsch.

## Kamera

- Die Kamera schaut immer schräg von oben nach Norden und folgt Hopper mit festem Abstand (0, 10, 10,5). Das Sichtfeld beträgt 40°.
- Das Steuerkreuz ist an die Himmelsrichtungen gebunden: oben heißt Norden, also vom Betrachter weg.
- Hinter der Welt hängt ein Himmel mit Farbverlauf, der an der Kamera befestigt ist.

## Ablauf eines Bilds

- `FrameClock` (CADisplayLink) ruft pro Bild `Game.step` auf. Darin passieren Bewegung, Hüpfen, Kamera, Münzen und Einsammeln.
- Spielstand, der bleiben soll, liegt lokal in `UserDefaults`, zum Beispiel `coins`.

## Prüfen ohne Mac

- CI baut die App, startet sie im iPhone-Simulator und macht Screenshots. Die Bilder stehen im Log zwischen `SCREENSHOT-BEGIN <name>` und `SCREENSHOT-END <name>` als Base64-JPEG und zusätzlich als Artefakt `screenshots`: `start` zeigt die Heimatinsel, `talk` ein Gespräch mit dem Hund am Start (Startargument `-screenshotTalk YES`), `village` ein erzeugtes Dorf. Mit dem Startargument `-screenshotStart x,z` beginnt Hopper an einer anderen Stelle. Weil das iPhone im Hochformat bootet, liegt das Querformat-Spiel im Bild um 90° gedreht.
