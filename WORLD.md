# Welt-Regeln

Pixel Hop ist eine 3D-Welt aus Blöcken mit Pixel-Texturen. Diese Regeln gelten für alles, was neu dazukommt.

## Maße

- **1 Block = 1 × 1 × 1** (RealityKit-Einheit, gedacht als Meter).
- **1 Pixel = 0,1**: Jede Block-Textur hat 10 × 10 Pixel, jedes Voxel-Modell besteht aus Würfeln mit 0,1 Kantenlänge. Dadurch hat alles in der Welt dieselbe Pixelgröße.
- Achsen: x nach Osten, y nach oben, z nach Süden. Norden ist auf dem Bildschirm oben.
- Kartenzeile 0 liegt im Norden bei z = 0, Spalte 0 im Westen bei x = 0. Die Kachel (Spalte, Zeile) belegt x ∈ [Spalte, Spalte + 1], z ∈ [Zeile, Zeile + 1].

## Karte

- `PixelHop/WorldMap.swift`: ASCII-Karte, ein Zeichen pro Kachel.
- Jedes Zeichen ist ein **Block** (`Block` in `PixelHop/Textures.swift`) mit Textur oben, Textur seitlich, Höhe der Oberkante und der Angabe, ob man durchlaufen kann.
- Jedes Zeichen kann zusätzlich ein **Requisit** tragen (`Models.props`), also ein Voxel-Modell, das mittig auf der Kachel steht.

| Zeichen | Block | Requisit | Begehbar |
|---|---|---|---|
| `.` | Gras | – | ja |
| `*` | Gras mit Blumen | – | ja |
| `=` | Sandweg | – | ja |
| `#` | Holzsteg | – | ja |
| `~` | Wasser, Oberkante −0,2 | – | nein |
| `T` | Gras | Baum | nein |
| `R` | Gras | Stein | nein |
| `C` | Gras | Münze | ja |
| `@` | Gras | Startpunkt von Hopper | ja |

- Ist eine Nachbarkachel niedriger, bekommt der Block dort eine Seitenwand. Am Kartenrand reicht sie bis y = −1, dadurch wirkt die Welt wie ein Diorama.

## Farben und Texturen

- Alle Farben kommen aus `Palette.colors`. Neue Farben kommen dort mit einem Buchstaben dazu.
- Texturen sind ASCII mit 10 × 10 Zeichen in `Textures.all`. Zeile 0 ist bei Oberseiten Norden und bei Seitenwänden oben.
- Alles landet in einer einzigen Textur, dem **Atlas** (`Atlas.swift`), mit Pixel-genauer Abtastung ohne Weichzeichnen.
- **Licht ist eingebacken**: Jede Würfelseite hat eine feste Helligkeit (`Face.brightness`). Oben 100 %, Süden 86 %, Westen 78 %, Osten 68 %, Norden 60 %, unten 50 %. Das Licht kommt also von oben links vorne. Die Materialien sind unbeleuchtet (`UnlitMaterial`), damit die Palette-Farben genau so erscheinen.

## Voxel-Modelle

- `VoxelModel` in `PixelHop/VoxelModel.swift`, die Modelle selbst stehen in `PixelHop/Models.swift`.
- Modelle werden aus Formen gebaut: `box` (Quader) und `ball` (Ellipsoid), je mit einer Palette-Farbe oder einer Farb-Regel pro Voxel.
- Der Drehpunkt liegt unten in der Mitte. Ein Modell, das eine Kachel ausfüllt, ist 10 × 10 Voxel groß.
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
