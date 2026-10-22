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
- Jedes Zeichen ist ein **Block** (`Block` in `PixelHop/Textures.swift`) mit Textur oben, Textur seitlich, Textur für tiefe Wände (`wall`, sonst Erde mit Steinen), Höhe der Oberkante und der Angabe, ob man durchlaufen kann.
- Zusätzlich hat jede Kachel eine **Höhenstufe** (`WorldMap.level`, siehe Berge). Die Oberkante liegt bei Blockhöhe + Stufe × 0,5.
- Jedes Zeichen kann zusätzlich ein **Requisit** tragen (`Models.props`). Das ist ein Voxel-Modell, oft in mehreren **Varianten**, mit einer **Grundfläche** in Kacheln. Eine 3 × 3-Grundfläche schreibt man, indem man das Zeichen 3 × 3-mal in die Karte setzt. Gleiche Zeichen nebeneinander ergeben mehrere Häuser, aufgeteilt von links oben aus. Das Modell steht mittig auf der Grundfläche, auf der Höhe seines Blocks.

| Zeichen | Block | Höhe | Requisit (Grundfläche) | Begehbar |
|---|---|---|---|---|
| `,` | Kopfsteinpflaster, Kaimauer als Seite | 0 | – | ja |
| `.` | Gras | 0 | – | ja |
| `*` | Gras mit bunten Blumen | 0 | – | ja |
| `%` | Gras mit blauen Blumen | 0 | – | ja |
| `^` | Schnee, Fels als Wand | 0 | – | ja |
| `=` | Sandweg | 0 | – | ja |
| `:` | Strand | −0,3 | – | ja |
| `#` | Holzsteg | 0 | – | ja |
| `~` | Wasser | −0,8 | – | nein |
| `o` | Wasser | −0,8 | Segelboot | nein |
| `H` | Pflaster | 0 | Haus (3 × 3): Sandstein/rot, weiß/blau oder grau/türkis | nein |
| `G` | Pflaster | 0 | Haus (3 × 3): rot/orange, gelb/rot oder rosa/lila | nein |
| `L` | Pflaster | 0 | Leuchtturm (2 × 2) | nein |
| `P` | Pflaster | 0 | Laterne | nein |
| `B` | Pflaster | 0 | Bank | nein |
| `F` | Pflaster | 0 | Blumenbusch im Topf | nein |
| `Y` | Strand | −0,3 | Palme | nein |
| `T` | Gras | 0 | Baum: Tanne, Birke, Laubbaum, Herbstbaum oder Kirschblüte | nein |
| `R` | Gras | 0 | Stein, glatt oder bemoost | nein |
| `&` | Schnee | 0 | Stein mit Schneehaube | nein |
| `C` `c` `d` `s` | Pflaster, Gras, Steg, Strand | je nach Block | Münze | ja |
| `@` | Pflaster | 0 | Startpunkt von Hopper | ja |

- Ist eine Nachbarkachel niedriger, bekommt der Block dort eine Seitenwand. Weil das Wasser tiefer liegt, entstehen am Wasser 0,8 hohe Kaimauern. Ist die Wand höher als 1, wird sie in Stücke von 1 geteilt: oben die Seitentextur (mit Grasnarbe oder Schneekante), darunter die Wand-Textur.
- Gras bekommt auf 12 % der Kacheln (Hash) die Variante mit Gänseblümchen (`Textures.pick`).
- Hopper und Münzen stehen immer auf der Höhe des Blocks unter ihnen.

## Unendliche Welt (`WorldGen.swift`)

Zufall gibt es nur über `Hash.value` (FNV-Hash) mit einem festen Seed pro Regel. Rauschen ist Wert-Rauschen mit zwei Oktaven (`fbm`). Die Regeln gelten der Reihe nach, die erste passende gewinnt:

1. **Heimat-Ring**: Bis 3 Kacheln um die Heimatinsel ist Wiese, damit die Brücken frei ankommen.
2. **Höhe**: Höhen-Rauschen mit Maßstab 38. Nahe der Heimat gibt es einen Bonus, deshalb ist dort Land. Unter −0,15 ist Wasser `~`, unter −0,08 Strand `:` mit 4 % Palmen `Y` und 1 % Münzen `s`.
3. **Dörfer**: Die Welt ist in Zellen von 6 × 6 Kacheln geteilt. Eine Zelle ist Dorf, wenn in ihrer Mitte das Dorf-Rauschen (Maßstab 70) über 0,22 liegt, dort Land ist und sie mehr als 10 Kacheln von der Heimat entfernt liegt.
   - Die erste Zeile und Spalte jeder Zelle ist Straße `,`.
   - 70 % der Zellen haben ein Haus `H`/`G` (3 × 3, ab Position 1,1), daneben eine Laterne, manchmal einen Busch und eine Bank. Die anderen Zellen sind kleine Plätze mit Bäumen, Büschen und einer Laterne.
   - Ein Haus gibt es nur, wenn alle 9 Kacheln Land sind.
   - Dörfer gibt es nur, wo das Berg-Rauschen in der Zellmitte unter 0,12 liegt. Dorfzellen sind immer flach (Stufe 0).
4. **Berge**: Über 11 Stufen liegt Schnee `^` mit 3 % verschneiten Steinen `&`.
5. **Feldwege** `=`: wo der Betrag des Weg-Rauschens (Maßstab 30) unter 0,035 liegt.
6. **Wald**: Wo das Wald-Rauschen (Maßstab 24) über 0,25 liegt, stehen auf 38 % der Kacheln Bäume.
7. **Blumenwiesen**: Wo das Blumen-Rauschen (Maßstab 20) über 0,3 liegt, sind 20 % bunte und 13 % blaue Blumen.
8. **Wiese**: sonst 2,5 % Bäume und 1,5 % Steine, je Höhenstufe mehr (+0,4 % Bäume, +0,8 % Steine), dazu 3,5 % bunte und 3,5 % blaue Blumen.
9. **Münzen**: 0,8 % auf Wiese und Wegen, 1–1,5 % auf Dorfstraßen.

Im tiefen Wasser schwimmen auf 0,3 % der Kacheln Segelboote `o`.

### Berge (`WorldGen.level`)

- Jede Kachel hat eine Höhenstufe ab 0. **Eine Stufe ist 0,5 hoch.**
- Stufe = (Berg-Rauschen mit Maßstab 44 − 0,12) × 28 × Küstenfaktor, abgerundet. Der Küstenfaktor wächst vom Strand (Höhe −0,08) bis Höhe 0,22 von 0 auf 1 und ist in den ersten 15 Kacheln um die Heimat kleiner. So steigen Berge sanft an und Ufer, Heimat und Dörfer bleiben auf Stufe 0.
- Ab Stufe 5 wachsen nur noch Tannen, ab Stufe 11 liegt Schnee.
- **Hopper und die Bewohner kommen bis zu 0,8 höher oder tiefer** (`WorldMap.canStep`): eine Stufe hoch hüpfen geht, eine Wand aus zwei Stufen (1,0) nicht.

### Varianten und Zufall

- Hat ein Requisit mehrere Varianten, wählt `WorldGen.variant` eine aus: zu 30 % reiner Zufall (Hash), sonst nach dem Gegend-Rauschen (Maßstab 40). So gibt es Gegenden mit Birken, Herbstwäldern oder Kirschblüten und Straßen mit ähnlichen Häusern, aber immer mit etwas Durcheinander.
- Natürliche Requisiten (Bäume, Steine, Büsche, Palmen, Boote) werden zufällig in 90°-Schritten gedreht und auf 85–120 % skaliert.

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

- `VoxelModel` in `PixelHop/VoxelModel.swift`. Die Modelle stehen in `PixelHop/Models.swift` (Gebäude, Hopper, Boot), `Nature.swift` (Bäume, Steine), `Animals.swift` (Bewohner) und `Critters.swift` (kleine Tiere und Effekte).
- Modelle werden aus Formen gebaut: `box` (Quader), `ball` (Ellipsoid) und `cylinder` (Säule, Radius pro Höhe), je mit einer Palette-Farbe oder einer Farb-Regel pro Voxel. Gibt die Farb-Regel `nil` zurück, bleibt das Voxel leer. Für Zufallsmuster gibt es `VoxelModel.noise`, das ist für jede Position immer gleich.
- Der Drehpunkt liegt unten in der Mitte. Ein Modell darf über seine Grundfläche hinausragen, etwa Palmwedel oder Dachüberstände.
- Gebäude schauen mit Tür und Fenstern nach Süden zur Kamera.
- Nur sichtbare Außenflächen werden gezeichnet. Gleichfarbige, aneinanderliegende Flächen werden zu großen Rechtecken zusammengefasst (Greedy Meshing), damit auch viele Häuser flüssig laufen.

## Hopper

- Hopper ist ein weißer Hase (`Models.hopper`), 9 × 15 × 10 Voxel groß, und schaut im Modell nach Süden.
- Die Hitbox ist 0,6 × 0,6 Blöcke. Läuft Hopper schräg vor eine Lücke, rutscht er automatisch in die Gasse.
- Beim Laufen hüpft er (Sinus, 0,25 hoch) und dreht sich weich in die Laufrichtung. Sein Schatten bleibt am Boden.
- Er läuft 3,2 Blöcke pro Sekunde. Seine Höhe gleitet weich zur Höhe der Kachel unter ihm, so sieht eine Stufe wie ein Hüpfer aus.

## Bewohner

- Bewohner sind Tiere aus Voxeln (`Animals.swift`), beschrieben als Arten in `Species.swift`:

| Kürzel | Art | Namen | schenkt eine Münze | Fundstück im Auftrag |
|---|---|---|---|---|
| `k` | Katze | Mimi, Karl, Luna | ja | Wollknäuel |
| `h` | Hund | Bello, Bruno, Rex | ja | Knochen |
| `c` | Huhn | Hilde, Gacki, Berta | nein | Goldenes Ei |
| `d` | Ente | Emma, Quaki, Paula | nein | Gummiente |
| `f` | Fuchs | Fred, Flinki, Rosa | ja | Landkarte |
| `q` | Frosch | Fritz, Quabbel, Kiki | nein | Krone |

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
  - Katzen, Hunde und Füchse schenken beim ersten normalen Gespräch (ohne Auftrag) eine Münze.
  - Das Textfeld schließt sich beim Antippen, nach 6 Sekunden oder wenn Hopper weggeht.
- Alle Texte sind kurz und auf Deutsch. Die Tiere sind **ironisch**: Sie tun cool, angeben oder gelangweilt und verraten sich dabei selbst („Ich bin der schlauste Fuchs der Welt. Hab mich heute nur dreimal verlaufen.“). Nie gemein zu Hopper, nie unheimlich.

## Aufträge und Grummel (`Adventure.swift`, `Quest.swift`, `QuestSite.swift`, `Grummels.swift`)

- **Wer fragt**: Alle Bewohner der Heimatinsel und jeder dritte Bewohner draußen (Hash). Jeder von ihnen hat **vier Aufträge nacheinander**, immer in dieser Reihenfolge. Es läuft immer nur ein Auftrag gleichzeitig.

| Nr. | Art | Was Hopper tun muss | Banner oben |
|---|---|---|---|
| 1 | Holen | das Fundstück der Art (`Species.errand`, Modelle in `Loot.swift`) bei den Grummeln abholen, 4 Wächter | „Gesucht: Knochen“ |
| 2 | Retten | das Tierbaby (`Species.baby`, das Modell der Art in klein) abholen. Es hüpft Hopper danach hinterher. 4 Wächter | „Rette: Küken“ |
| 3 | Sammeln | 3 Glitzersteine an 3 verschiedenen Orten, je 2 Wächter | „Glitzersteine: 1/3“ |
| 4 | Verjagen | 3 Grummel im Lager plattmachen, indem Hopper aus dem Flug auf ihnen landet. 5 Grummel im Lager | „Grummel verjagt: 1/3“ |

- **Wo**: Jeder Ort liegt 22–35 Kacheln vom Bewohner entfernt (Richtung und Abstand aus dem Hash, gemischt mit der Nummer des Auftrags). Sammelorte liegen mindestens 8 Kacheln auseinander. Jeder Ort muss begehbar sein, und auf der geraden Linie dorthin darf außerhalb der Heimatinsel kein Wasser und keine Wand über 0,8 liegen.
- **Aufheben** geht nur am Boden oder knapp darüber (unter 1,4 Höhe). Wer drüberfliegt, muss also landen.
- **Grummel**: Lila Stachel-Monster mit bösem Blick, 2–2,5 Kacheln neben jedem Ort. Ist Hopper näher als 6 Kacheln und weniger als 10 Kacheln von ihrem Platz weg, jagen sie ihn mit 2,1 Kacheln pro Sekunde (Hopper ist mit 3,2 schneller). Sonst hüpfen sie zurück auf ihren Platz.
- **Plattmachen**: Sinkt Hopper zwischen 0,25 und 1,4 Höhe durch die Luft (zum Beispiel beim Landen) und ist dabei näher als 0,8 an einem Grummel, wird der Grummel flachgedrückt und verschwindet. Das geht bei jedem Auftrag.
- **Herzen**: Hopper hat 3 Herzen (oben links unter den Münzen). Berührt ihn ein Grummel am Boden, verliert er ein Herz, wird weggestoßen, der Bildschirm blitzt rot und er blinkt 1,6 Sekunden lang. In der Zeit jagen ihn die Grummel nicht.
- **Ohnmacht**: Bei 0 Herzen wacht Hopper zu Hause am Start mit vollen Herzen auf. Alles Gefundene liegt dann wieder an seinem Ort, plattgemachte Grummel bleiben weg.
- **Pfeil**: Oben in der Mitte steht der Auftrag, und ein Pfeil zeigt zum nächsten offenen Ort. Ist alles erledigt, zeigt er zurück zum Bewohner.
- **Belohnung**: Ist der Auftrag erledigt und Hopper redet mit dem Bewohner, gibt es 5 Münzen und die Grummel verschwinden.

## Superkraft Fliegen (`Flight.swift`)

- Unten rechts ist der Flügel-Knopf. Antippen lässt Hopper abheben, nochmal antippen lässt ihn landen.
- Im Flug hat Hopper zwei weiße Flügel, die schlagen. Er schwebt 2,6 über dem Boden und folgt den Bergen. Er fliegt 5,5 Kacheln pro Sekunde, über Wasser, Bäume, Häuser und Wände hinweg.
- Der Schatten bleibt am Boden und wird kleiner, je höher Hopper ist.
- **Energie**: Die Leiste unter den Herzen reicht für 10 Sekunden Flug. Am Boden lädt sie in 6 Sekunden wieder voll. Abheben geht ab 20 %. Ist sie leer, sinkt Hopper.
- **Landen** geht nur auf freiem Boden. Über Wasser, Bäumen oder Wänden bleibt Hopper 0,6 hoch in der Luft und kann weiterlaufen, bis Platz zum Landen ist.
- Grummel kommen nicht an fliegende Hopper heran: Sie hören auf zu jagen und beißen nicht.

## Leben in der Welt (`Life.swift`)

Alles bewegt sich nur, wenn es in Hoppers Nähe ist. Ort und Takt kommen aus dem Hash, damit es nicht im Gleichschritt wackelt.

- **Bäume und Palmen** wiegen sich im Wind (±0,04 rad).
- **Boote** schaukeln auf dem Wasser.
- **Schornsteine** jedes Hauses rauchen: drei kleine graue Wölkchen steigen nacheinander 1,1 hoch, wachsen und verschwinden.
- **Schmetterlinge** flattern über 15 % der Blumenkacheln.
- **Möwen**: In 40 % der Chunks kreisen zwei Möwen 4,5 über dem Boden.
- **Glitzern**: Auf 4 % der Wasserkacheln blitzt ab und zu ein Lichtfunke auf.
- **Fische**: Alle 2–5 Sekunden springt in Hoppers Nähe ein Fisch im Bogen aus dem Wasser, mit Spritzern beim Ein- und Auftauchen.

## Töne und Vibration (`Cue.swift`, `Sounds.swift`)

- Jedes Ereignis ist ein `Cue`: Er spielt einen Ton und lässt das Handy passend vibrieren. Neue Ereignisse bekommen einen neuen Fall in `Cue`, nicht eigene Ton- oder Vibrationsaufrufe.
- Die Töne liegen als kurze WAV-Dateien (Mono, 22 kHz) in `PixelHop/Sounds/`. Sie stammen von **Kenney (kenney.nl), Lizenz CC0** (gemeinfrei), aus den Paketen *Impact Sounds*, *Interface Sounds*, *Digital Audio*, *RPG Audio* und *Music Jingles*. Neue Töne nur mit freier Lizenz (CC0) und mit Quelle hier eintragen.
- Die Audio-Sitzung ist `ambient`: Der Stummschalter am iPhone macht das Spiel leise, und Musik aus anderen Apps läuft weiter.

| Ereignis | Ton | Vibration |
|---|---|---|
| Hüpfer beim Laufen | Schritt auf Gras, Pflaster, Holz, Sand oder Schnee (3 Varianten, leise) | – |
| Stufe hoch oder runter | – | leicht |
| Steuerkreuz neue Richtung | – | Klick |
| Münze | Pling | weich |
| Reden | kurzes Frage-Piepen | Klick |
| Geschenk | Münzgeklimper | Erfolg |
| Auftrag annehmen | 8-Bit-Melodie aufwärts | mittel |
| Fundstück gefunden | 8-Bit-Melodie aufwärts | Erfolg |
| Auftrag erledigt | 8-Bit-Fanfare und Münzgeklimper | Erfolg |
| Grummel-Treffer | Schlag | stark und Fehler |
| Ohnmacht | 8-Bit-Melodie abwärts | Fehler |
| Grummel näher als 3 Kacheln | – | Herzschlag, je näher desto schneller |
| Fisch springt | Platschen | – |
| Abheben | Zisch nach oben | mittel |
| Flügelschlag | leises Flattern | ganz leicht |
| Landen | dumpfer Plumps | weich |
| Grummel plattgemacht | Boing | stark |

## Kamera

- Die Kamera schaut immer schräg von oben nach Norden und folgt Hopper mit festem Abstand (0, 10, 10,5). Das Sichtfeld beträgt 40°.
- Das Steuerkreuz ist an die Himmelsrichtungen gebunden: oben heißt Norden, also vom Betrachter weg.
- Hinter der Welt hängt ein Himmel mit Farbverlauf, der an der Kamera befestigt ist.

## Ablauf eines Bilds

- `FrameClock` (CADisplayLink) ruft pro Bild `Game.step` auf. Darin passieren Bewegung, Hüpfen, Kamera, Münzen und Einsammeln.
- Spielstand, der bleiben soll, liegt lokal in `UserDefaults`, zum Beispiel `coins`.

## Prüfen ohne Mac

- CI baut die App, startet sie im iPhone-Simulator und macht Screenshots. Die Bilder stehen im Log zwischen `SCREENSHOT-BEGIN <name>` und `SCREENSHOT-END <name>` als Base64-JPEG und zusätzlich als Artefakt `screenshots`: `start` zeigt die Heimatinsel, `talk` ein Gespräch mit dem Hund am Start (Startargument `-screenshotTalk YES`), `village` ein erzeugtes Dorf, `hills` einen Weg den Berg hinauf zum Schnee, `quest` Hopper bei den Grummeln des ersten Auftrags vom Hund (Startargument `-screenshotQuest YES`, dabei bleibt immer ein Herz übrig), `fly` Hopper fliegend am Start (`-screenshotFly YES`, mit unendlich Energie). Mit dem Startargument `-screenshotStart x,z` beginnt Hopper an einer anderen Stelle. Weil das iPhone im Hochformat bootet, liegt das Querformat-Spiel im Bild um 90° gedreht.
