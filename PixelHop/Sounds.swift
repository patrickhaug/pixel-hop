import AVFoundation

final class Sounds {
    static let shared = Sounds()

    private var players: [String: [AVAudioPlayer]] = [:]
    private var turn: [String: Int] = [:]

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func play(_ name: String, volume: Float = 1) {
        let list = players(for: name)
        guard !list.isEmpty else { return }
        let index = turn[name, default: 0] % list.count
        turn[name] = index + 1
        list[index].volume = volume
        list[index].currentTime = 0
        list[index].play()
    }

    private func players(for name: String) -> [AVAudioPlayer] {
        if let list = players[name] { return list }
        let url = Bundle.main.url(forResource: name, withExtension: "wav")
            ?? Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Sounds")
        let list = url.map { url in (0..<3).compactMap { _ in try? AVAudioPlayer(contentsOf: url) } } ?? []
        list.forEach { $0.prepareToPlay() }
        players[name] = list
        return list
    }
}
