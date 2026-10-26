//
//  MusicStore.swift
//  Spark
//
//  Purpose:
//  Spark Music playback intent and track selection.
//
//  Responsibilities:
//  • Tracks active track, queue intent, and player UI state.
//

import Foundation
import Observation

@Observable
final class MusicStore {
    private struct Payload: Codable {
        var favorites: [String]
        var lastTrackId: String?
    }

    var currentTrackId: String?
    var isPlaying = false
    private(set) var favorites: [String] = []
    private(set) var lastTrackId: String?

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let payload = Self.load(from: userDefaults, decoder: decoder) {
            favorites = payload.favorites
            lastTrackId = payload.lastTrackId
        }
    }

    func playTrack(_ id: String) {
        currentTrackId = id
        isPlaying = true
        lastTrackId = id
        persist()
    }

    func togglePlayPause() {
        if currentTrackId == nil {
            let startID = lastTrackId ?? MusicLibrary.tracks.first?.id
            guard let startID else { return }
            playTrack(startID)
            return
        }
        isPlaying.toggle()
    }

    func pause() {
        isPlaying = false
    }

    func next() {
        guard let nextID = MusicLibrary.stepTrack(from: currentTrackId, direction: 1) else { return }
        playTrack(nextID)
    }

    func previous() {
        guard let previousID = MusicLibrary.stepTrack(from: currentTrackId, direction: -1) else { return }
        playTrack(previousID)
    }

    func stop() {
        currentTrackId = nil
        isPlaying = false
    }

    func toggleFavorite(_ id: String) {
        if favorites.contains(id) {
            favorites.removeAll { $0 == id }
        } else {
            favorites.append(id)
        }
        persist()
    }

    func isFavorite(_ id: String) -> Bool {
        favorites.contains(id)
    }

    private func persist() {
        do {
            let data = try encoder.encode(Payload(favorites: favorites, lastTrackId: lastTrackId))
            userDefaults.set(data, forKey: Storage.key)
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
        }
    }

    private static func load(from userDefaults: UserDefaults, decoder: JSONDecoder) -> Payload? {
        guard let data = userDefaults.data(forKey: Storage.key) else { return nil }
        do {
            return try decoder.decode(Payload.self, from: data)
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
            return nil
        }
    }

    private enum Storage {
        static let key = "spark-music"
    }
}
