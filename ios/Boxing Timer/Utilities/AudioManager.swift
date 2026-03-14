import AudioToolbox
import AVFoundation
import Foundation

final class AudioManager {
    static let shared = AudioManager()

    private var keepAlivePlayer: AVAudioPlayer?
    private let keepAliveURL = FileManager.default.temporaryDirectory.appendingPathComponent("boxing-timer-silence.wav")

    private init() {}

    var isBackgroundPlaybackActive: Bool {
        keepAlivePlayer?.isPlaying == true
    }

    private var bellsType: Int {
        PersistenceManager.shared.loadSettings().bellsType
    }

    func playRoundStart() {
        playSystemSound(startBellSoundID(for: bellsType))
    }

    func playRoundEnd() {
        playSystemSound(endBellSoundID(for: bellsType))
    }

    func playBreakStart() {
        playSystemSound(1057)
    }

    func playNoticeWarning() {
        playSystemSound(1103)
    }

    func playGetReady() {
        playSystemSound(1110)
    }

    func playWorkoutComplete() {
        playRoundEnd()
        for delay in [0.3, 0.6] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.playRoundEnd()
            }
        }
    }

    func playPreview(bellType: Int) {
        playSystemSound(startBellSoundID(for: bellType))
    }

    func beginBackgroundPlayback() {
        do {
            if !FileManager.default.fileExists(atPath: keepAliveURL.path) {
                try makeSilentLoopFile(at: keepAliveURL)
            }

            keepAlivePlayer = try AVAudioPlayer(contentsOf: keepAliveURL)
            keepAlivePlayer?.numberOfLoops = -1
            keepAlivePlayer?.volume = 1
            keepAlivePlayer?.prepareToPlay()
            keepAlivePlayer?.play()
        } catch {
            print("Background playback setup failed: \(error)")
        }
    }

    func endBackgroundPlayback() {
        keepAlivePlayer?.stop()
        keepAlivePlayer = nil
    }

    private func startBellSoundID(for bellType: Int) -> SystemSoundID {
        switch bellType {
        case 2: return 1016
        case 3: return 1025
        default: return 1013
        }
    }

    private func endBellSoundID(for bellType: Int) -> SystemSoundID {
        switch bellType {
        case 2: return 1017
        case 3: return 1026
        default: return 1014
        }
    }

    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }

    private func makeSilentLoopFile(at url: URL) throws {
        let sampleRate = 44_100
        let channels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let durationSeconds = 1
        let frameCount = sampleRate * durationSeconds
        let bytesPerSample = Int(bitsPerSample / 8)
        let dataSize = frameCount * Int(channels) * bytesPerSample
        let byteRate = sampleRate * Int(channels) * bytesPerSample
        let blockAlign = Int(channels) * bytesPerSample

        var data = Data()
        data.append(contentsOf: Array("RIFF".utf8))
        data.append(UInt32(36 + dataSize).littleEndianData)
        data.append(contentsOf: Array("WAVE".utf8))
        data.append(contentsOf: Array("fmt ".utf8))
        data.append(UInt32(16).littleEndianData)
        data.append(UInt16(1).littleEndianData)
        data.append(channels.littleEndianData)
        data.append(UInt32(sampleRate).littleEndianData)
        data.append(UInt32(byteRate).littleEndianData)
        data.append(UInt16(blockAlign).littleEndianData)
        data.append(bitsPerSample.littleEndianData)
        data.append(contentsOf: Array("data".utf8))
        data.append(UInt32(dataSize).littleEndianData)
        data.append(Data(count: dataSize))
        try data.write(to: url, options: .atomic)
    }
}

private extension FixedWidthInteger {
    var littleEndianData: Data {
        withUnsafeBytes(of: littleEndian) { Data($0) }
    }
}
