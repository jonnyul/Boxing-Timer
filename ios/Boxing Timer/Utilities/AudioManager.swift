import AudioToolbox
import AVFoundation
import Foundation

final class AudioManager {
    static let shared = AudioManager()

    private var keepAlivePlayer: AVAudioPlayer?
    private let keepAliveURL = FileManager.default.temporaryDirectory.appendingPathComponent("boxing-timer-silence.wav")

    // Custom sound players — preloaded at init so first play has no latency.
    private var roundStartPlayer: AVAudioPlayer?
    private var roundEndNoticePlayer: AVAudioPlayer?

    private init() {
        roundStartPlayer = makePlayer(named: "round_start")
        roundEndNoticePlayer = makePlayer(named: "round_end_notice")
    }

    var isBackgroundPlaybackActive: Bool {
        keepAlivePlayer?.isPlaying == true
    }

    func playRoundStart() {
        playCustom(roundStartPlayer)
    }

    func playRoundEnd() {
        // No custom file for round end yet — falls back to system sound.
        playSystemSound(1014)
    }

    func playBreakStart() {
        playSystemSound(1057)
    }

    func playNoticeWarning() {
        playCustom(roundEndNoticePlayer)
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

    private func makePlayer(named name: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("AudioManager: missing \(name).wav in bundle")
            return nil
        }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        return player
    }

    private func playCustom(_ player: AVAudioPlayer?) {
        player?.currentTime = 0
        player?.play()
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
