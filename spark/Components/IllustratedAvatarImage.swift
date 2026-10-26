//
//  IllustratedAvatarImage.swift
//  Spark
//
//  Purpose:
//  Cached network loader for DiceBear illustrated avatars.
//
//  Responsibilities:
//  • Fetches and caches avatar images with deduplication and retry.
//  • Supports direct rendering from avatar builder configuration.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Cached DiceBear loader for illustrated avatars.
enum IllustratedAvatarImageLoader {
    #if canImport(UIKit)
    private static let memoryCache = NSCache<NSString, UIImage>()

    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache.shared
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.httpMaximumConnectionsPerHost = 8
        return URLSession(configuration: configuration)
    }()
    #endif

    private actor Coordinator {
        static let shared = Coordinator()
        private var inFlight: [String: Task<UIImage?, Never>] = [:]

        func image(for url: URL) async -> UIImage? {
            #if canImport(UIKit)
            let key = url.absoluteString
            if let cached = IllustratedAvatarImageLoader.memoryCache.object(forKey: key as NSString) {
                return cached
            }

            if let existing = inFlight[key] {
                return await existing.value
            }

            let task = Task<UIImage?, Never> {
                await IllustratedAvatarImageLoader.fetch(url: url)
            }

            inFlight[key] = task
            let result = await task.value
            inFlight[key] = nil
            return result
            #else
            return nil
            #endif
        }
    }

    #if canImport(UIKit)
    static func cachedImage(for url: URL) -> UIImage? {
        memoryCache.object(forKey: url.absoluteString as NSString)
    }

    private static func fetch(url: URL, attempt: Int = 0) async -> UIImage? {
        let key = url.absoluteString as NSString
        if let cached = memoryCache.object(forKey: key) {
            return cached
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  (200 ... 299).contains(http.statusCode),
                  let image = UIImage(data: data) else {
                if attempt < 1 {
                    try? await Task.sleep(nanoseconds: 250_000_000)
                    return await fetch(url: url, attempt: attempt + 1)
                }
                return nil
            }
            memoryCache.setObject(image, forKey: key)
            return image
        } catch {
            if attempt < 1, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 250_000_000)
                return await fetch(url: url, attempt: attempt + 1)
            }
            return nil
        }
    }
    #endif

    static func load(url: URL) async -> UIImage? {
        await Coordinator.shared.image(for: url)
    }
}

struct IllustratedAvatarImage: View {
    let url: URL
    var placeholderColor: Color = SparkColors.lavenderSoft
    var showsPlaceholderIcon: Bool = false

    #if canImport(UIKit)
    @State private var loadedImage: UIImage?
    #endif
    @State private var loadFailed = false

    var body: some View {
        Group {
            #if canImport(UIKit)
            if let displayImage {
                Image(uiImage: displayImage)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
                    .task(id: url.absoluteString) {
                        loadFailed = false

                        if let cached = IllustratedAvatarImageLoader.cachedImage(for: url) {
                            loadedImage = cached
                            return
                        }

                        loadedImage = nil
                        let image = await IllustratedAvatarImageLoader.load(url: url)
                        guard !Task.isCancelled else { return }
                        loadedImage = image
                        loadFailed = image == nil
                    }
            }
            #else
            placeholder
            #endif
        }
    }

    #if canImport(UIKit)
    private var displayImage: UIImage? {
        loadedImage ?? IllustratedAvatarImageLoader.cachedImage(for: url)
    }
    #endif

    private var placeholder: some View {
        Circle()
            .fill(placeholderColor)
            .overlay {
                if showsPlaceholderIcon && loadFailed {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(SparkColors.lavender.opacity(0.35))
                }
            }
    }
}

/// Renders a DiceBear avatar directly from builder configuration JSON.
struct AvatarConfigImage: View {
    let config: AvatarConfig
    var pixelSize: Int
    var placeholderColor: Color?

    init(
        config: AvatarConfig,
        pixelSize: Int = 128,
        placeholderColor: Color? = nil
    ) {
        self.config = config
        self.pixelSize = pixelSize
        self.placeholderColor = placeholderColor
    }

    var body: some View {
        if let url = SparkAvatarCatalog.url(for: config, size: pixelSize) {
            IllustratedAvatarImage(
                url: url,
                placeholderColor: placeholderColor ?? SparkAvatarCatalog.placeholderColor(for: config),
                showsPlaceholderIcon: false
            )
            .id(url.absoluteString)
        } else {
            Circle()
                .fill(placeholderColor ?? SparkColors.lavenderSoft)
        }
    }
}
