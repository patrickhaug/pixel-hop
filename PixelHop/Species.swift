struct Species {
    let kind: String
    let model: VoxelModel
    let speed: Float
    let names: [String]
    let lines: [String]
    let gives: Bool

    static let all: [Character: Species] = [
        "k": Species(
            kind: "Katze",
            model: Animals.cat,
            speed: 1.2,
            names: ["Mimi", "Karl", "Luna"],
            lines: [
                "Miau! Hast du die Fischerboote am Hafen gesehen?",
                "Ich schlafe am liebsten in der Sonne auf dem Pflaster.",
                "Psst … im Wald glitzert manchmal eine Münze!",
            ],
            gives: true
        ),
        "h": Species(
            kind: "Hund",
            model: Animals.dog,
            speed: 1.6,
            names: ["Bello", "Bruno", "Rex"],
            lines: [
                "Wuff! Ich passe auf das Dorf auf!",
                "Hinter den Bäumen geht die Welt immer weiter, wuff!",
                "Wollen wir um die Wette rennen? Du hüpfst so schnell!",
            ],
            gives: true
        ),
        "c": Species(
            kind: "Huhn",
            model: Animals.chicken,
            speed: 0.9,
            names: ["Hilde", "Gacki", "Berta"],
            lines: [
                "Gack gack! Ich habe heute drei Eier gelegt!",
                "Pass auf, dass du nicht in die Blumen hüpfst!",
                "Gaaack! Ein Hase! Ach, du bist es, Hopper.",
            ],
            gives: false
        ),
        "d": Species(
            kind: "Ente",
            model: Animals.duck,
            speed: 0.9,
            names: ["Emma", "Quaki", "Paula"],
            lines: [
                "Quak! Das Wasser ist heute herrlich!",
                "Ich schwimme gleich rüber zum Leuchtturm.",
                "Quak quak! Hast du auch so kalte Füße?",
            ],
            gives: false
        ),
        "f": Species(
            kind: "Fuchs",
            model: Animals.fox,
            speed: 1.8,
            names: ["Fred", "Flinki", "Rosa"],
            lines: [
                "Hallo Hopper! Ich kenne jeden Weg im Wald.",
                "Ich bin schnell, aber du hüpfst höher!",
                "Im Wald ist es schön ruhig. Hörst du die Vögel?",
            ],
            gives: true
        ),
        "q": Species(
            kind: "Frosch",
            model: Animals.frog,
            speed: 1.0,
            names: ["Fritz", "Quabbel", "Kiki"],
            lines: [
                "Quaaak! Ich hüpfe genau wie du!",
                "Hast du eine Fliege gesehen? Ich hab so Hunger.",
                "Früher war ich mal die Hauptfigur in diesem Spiel!",
            ],
            gives: false
        ),
    ]

    static let gift = "Hier, die hab ich gefunden. Die ist für dich!"
}
