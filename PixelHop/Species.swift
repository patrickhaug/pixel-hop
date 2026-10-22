struct Species {
    let kind: String
    let model: VoxelModel
    let speed: Float
    let names: [String]
    let lines: [String]
    let gives: Bool
    let baby: String
    let errand: Errand

    static let all: [Character: Species] = [
        "k": Species(
            kind: "Katze",
            model: Animals.cat,
            speed: 1.2,
            names: ["Mimi", "Karl", "Luna"],
            lines: [
                "Oh, ein Hase. Wie aufregend. Ich bin begeistert. Wirklich.",
                "Ich hab heute schon 18 Stunden geschlafen. Ich bin total erschöpft.",
                "Mäuse fangen? Nee. Dafür hab ich Personal.",
            ],
            gives: true,
            baby: "Kätzchen",
            errand: Errand(
                item: "Wollknäuel",
                model: Loot.wool,
                ask: "Ein Grummel hat mein Wollknäuel geklaut. Nicht dass es mir wichtig wäre. Hol es zurück. Sofort. Bitte.",
                waiting: "Und? Wo ist mein Wollknäuel? Folg dem Pfeil, Hase.",
                thanks: "Mein Wollknäuel! Ich meine … ach, ganz nett. Hier, 5 Münzen."
            )
        ),
        "h": Species(
            kind: "Hund",
            model: Animals.dog,
            speed: 1.6,
            names: ["Bello", "Bruno", "Rex"],
            lines: [
                "Wuff! Ich bewache das Dorf! Also … meistens schlafe ich. Aber sehr wachsam!",
                "Ich jage meinen Schwanz. Irgendwann krieg ich ihn!",
                "Wollen wir um die Wette rennen? Ich lass dich gewinnen. Absichtlich. Ehrlich.",
            ],
            gives: true,
            baby: "Hündchen",
            errand: Errand(
                item: "Knochen",
                model: Loot.bone,
                ask: "Die Grummel haben meinen Lieblingsknochen! Ich würde ihn ja selbst holen, aber ich muss hier ganz dringend wachen.",
                waiting: "Der Knochen ist noch bei den Grummeln. Ich warte hier. Mutig.",
                thanks: "MEIN KNOCHEN! Wuff! Du bist der beste Hase der Welt! Hier, 5 Münzen."
            )
        ),
        "c": Species(
            kind: "Huhn",
            model: Animals.chicken,
            speed: 0.9,
            names: ["Hilde", "Gacki", "Berta"],
            lines: [
                "Gack. Ich lege Eier. Jeden Tag. Superspannend.",
                "Warum ich über die Straße gehe? Geht dich gar nichts an!",
                "Ich kann fliegen! Ungefähr einen halben Meter.",
            ],
            gives: false,
            baby: "Küken",
            errand: Errand(
                item: "Goldenes Ei",
                model: Loot.egg,
                ask: "Ein Grummel hat mein goldenes Ei geklaut! Ich hab genau eins. EINS!",
                waiting: "Mein Ei! Mein armes Ei! Folg dem Pfeil!",
                thanks: "Mein Ei! Gack! Aus Dankbarkeit lege ich dir … 5 Münzen hin."
            )
        ),
        "d": Species(
            kind: "Ente",
            model: Animals.duck,
            speed: 0.9,
            names: ["Emma", "Quaki", "Paula"],
            lines: [
                "Quak. Ich schwimme im Kreis. Ist ein Hobby.",
                "Kalte Füße? Ich? Niemals. Bibber.",
                "Ich bin eine Ente, kein Schwan. Danke, dass du fragst.",
            ],
            gives: false,
            baby: "Entchen",
            errand: Errand(
                item: "Gummiente",
                model: Loot.duck,
                ask: "Die Grummel haben meine Gummiente. Nein, das ist überhaupt nicht peinlich. Hol sie einfach.",
                waiting: "Die Gummiente ist noch weg. Ich schwimme so lange im Kreis.",
                thanks: "Meine Gummiente! Quak! Erzähl das bitte niemandem. Hier, 5 Münzen."
            )
        ),
        "f": Species(
            kind: "Fuchs",
            model: Animals.fox,
            speed: 1.8,
            names: ["Fred", "Flinki", "Rosa"],
            lines: [
                "Ich bin der schlauste Fuchs der Welt. Hab mich heute nur dreimal verlaufen.",
                "Ich bin super schnell. Außer bergauf. Und bergab. Und geradeaus.",
                "Grummel? Gefährlich. Aber nicht so gefährlich wie ich. Glaub ich.",
            ],
            gives: true,
            baby: "Füchslein",
            errand: Errand(
                item: "Landkarte",
                model: Loot.chart,
                ask: "Mein genialer Plan: Ich hab den Grummeln meine Landkarte geliehen. Jetzt ist sie weg. Hilfst du mir?",
                waiting: "Ohne Landkarte verlaufe ich mich. Noch öfter als sonst.",
                thanks: "Meine Landkarte! Jetzt weiß ich endlich, wo ich bin. Hier, 5 Münzen."
            )
        ),
        "q": Species(
            kind: "Frosch",
            model: Animals.frog,
            speed: 1.0,
            names: ["Fritz", "Quabbel", "Kiki"],
            lines: [
                "Früher war ich mal die Hauptfigur in diesem Spiel. Jetzt sag ich nur noch Quak.",
                "Ich bin kein verzauberter Prinz. Leider. Hab's ausprobiert.",
                "Fliegen sind lecker. Willst du auch eine? Nein? Mehr für mich.",
            ],
            gives: false,
            baby: "Fröschlein",
            errand: Errand(
                item: "Krone",
                model: Loot.crown,
                ask: "Die Grummel haben meine Krone! Ja, ich hatte eine. Ich war mal die Hauptfigur!",
                waiting: "Ohne Krone bin ich nur ein ganz normaler Frosch. Schrecklich.",
                thanks: "Meine Krone! Ich bin wieder wichtig! Hier, 5 Münzen."
            )
        ),
    ]

    static let gift = "Hier, die hab ich gefunden. Brauch ich nicht. Glänzt mir zu sehr."
}
