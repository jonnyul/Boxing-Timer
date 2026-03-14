import Combine
import Foundation

@MainActor
final class PresetsViewModel: ObservableObject {
    @Published var presets: [Preset] = []

    init() {
        loadPresets()
    }

    func loadPresets() {
        presets = PersistenceManager.shared.loadPresets()
    }

    func addPreset(_ preset: Preset) {
        presets.append(preset)
        PersistenceManager.shared.savePresets(presets)
    }

    func updatePreset(_ preset: Preset) {
        guard let index = presets.firstIndex(where: { $0.id == preset.id }) else { return }
        presets[index] = preset
        PersistenceManager.shared.savePresets(presets)
    }

    func deletePreset(id: UUID) {
        presets.removeAll { $0.id == id }
        PersistenceManager.shared.savePresets(presets)
    }
}
