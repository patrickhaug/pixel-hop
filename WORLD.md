# Welt-Regeln

Pixel Hop ist eine 3D-Welt aus Blöcken mit Pixel-Texturen. Diese Regeln gelten für alles, was neu dazukommt.

## Maße

- **1 Block = 1 × 1 × 1** (RealityKit-Einheit, gedacht als Meter).
- **Block-Texturen: 16 × 16 Pixel** pro Fläche, ein Texel ist also 1/16 Block.
- **Voxel-Modelle: Würfel mit 0,1 Kantenlänge**, ein Modell über eine Kachel ist also 10 × 10 Voxel groß.
- Achsen: x nach Osten, y nach oben, z nach Süden. Norden ist auf dem Bildschirm oben.
- Kartenzeile 0 liegt im Norden bei z = 0, Spalte 0 im Westen bei x = 0. Die Kachel (Spalte, Zeile) belegt x ∈ [Spalte, Spalte + 1], z ∈ [Zeile, Zeile + 1].

## Karte

- `PixelHop/WorldMap.swift`: ASCII-Karte, ein Zeichen pro Kachel. Die Welt ist eine Hafenstadt auf einer Insel. Am Rand ist Wasser.
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

- Ist eine Nachbarkachel niedriger, bekommt der Block dort eine Seitenwand. Weil das Wasser tiefer liegt, entstehen am Wasser 0,8 hohe Kaimauern. Am Kartenrand reicht die Wand bis y = −1.
- Hopper und Münzen stehen immer auf der Höhe des Blocks unter ihnen.

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
- Nur sichtbare Außenflächen werden gezeichnet.

## Hopper

- Hopper ist ein weißer Hase (`Models.hopper`), 9 × 15 × 10 Voxel groß, und schaut im Modell nach Süden.
- Die Hitbox ist 0,6 × 0,6 Blöcke. Läuft Hopper schräg vor eine Lücke, rutscht er automatisch in die Gasse.
- Beim Laufen hüpft er (Sinus, 0,25 hoch) und dreht sich weich in die Laufrichtung. Sein Schatten bleibt am Boden.
- Er läuft 3,2 Blöcke pro Sekunde.

## Kamera

- Die Kamera schaut immer schräg von oben nach Norden und folgt Hopper mit festem Abstand (0, 7,5, 8). Das Sichtfeld beträgt 40°.
- Das Steuerkreuz ist an die Himmelsrichtungen gebunden: oben heißt Norden, also vom Betrachter weg.
- Hinter der Welt hängt ein Himmel mit Farbverlauf, der an der Kamera befestigt ist.

## Ablauf eines Bilds

- `FrameClock` (CADisplayLink) ruft pro Bild `Game.step` auf. Darin passieren Bewegung, Hüpfen, Kamera, Münzen und Einsammeln.
- Spielstand, der bleiben soll, liegt lokal in `UserDefaults`, zum Beispiel `coins`.

## Prüfen ohne Mac

- CI baut die App, startet sie im iPhone-Simulator und macht einen Screenshot. Das Bild steht im Log zwischen `SCREENSHOT-BEGIN` und `SCREENSHOT-END` als Base64-JPEG und zusätzlich als Artefakt `screenshot`. Weil das iPhone im Hochformat bootet, liegt das Querformat-Spiel im Bild um 90° gedreht.
