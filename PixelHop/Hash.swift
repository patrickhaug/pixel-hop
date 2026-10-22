enum Hash {
    static func value(_ values: Int...) -> UInt32 {
        var hash: UInt32 = 2_166_136_261
        for value in values {
            hash = (hash ^ UInt32(truncatingIfNeeded: value)) &* 16_777_619
        }
        return hash
    }
}
