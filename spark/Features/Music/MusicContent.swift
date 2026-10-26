//
//  MusicContent.swift
//  Spark
//
//  Purpose:
//  Static music feature copy and UI helpers.
//
//  Responsibilities:
//  • Provides track grouping and presentation metadata.
//

import SwiftUI

enum MusicFilter: Hashable {
    case all
    case favorites
    case category(TrackCategory)

    var label: String {
        switch self {
        case .all:
            return "All"
        case .favorites:
            return "❤ Favorites"
        case .category(let category):
            return category.displayName
        }
    }
}

enum MusicContent {
    static let filters: [MusicFilter] = [
        .all,
        .favorites,
    ] + MusicLibrary.categories.map { .category($0) }

    static func tracks(for filter: MusicFilter, favorites: [String]) -> [MusicTrack] {
        switch filter {
        case .all:
            return MusicLibrary.tracks
        case .favorites:
            return MusicLibrary.tracks.filter { favorites.contains($0.id) }
        case .category(let category):
            return MusicLibrary.tracks(in: category)
        }
    }
}

struct TrackArtworkView: View {
    let urlString: String
    var size: CGFloat = 60
    var cornerRadius: CGFloat = SparkRadius.md

    var body: some View {
        Group {
            if let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        artworkPlaceholder
                    }
                }
            } else {
                artworkPlaceholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .accessibilityHidden(true)
    }

    private var artworkPlaceholder: some View {
        ZStack {
            SparkColors.lavenderSoft
            Image(systemName: "music.note")
                .font(.system(size: size * 0.35, weight: .semibold))
                .foregroundStyle(SparkColors.lavender)
        }
    }
}
