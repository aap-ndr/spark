//
//  SafariView.swift
//  Spark
//
//  Purpose:
//  SFSafariViewController wrapper for in-app web browsing.
//
//  Responsibilities:
//  • Presents external links without leaving the Spark app shell.
//

import SafariServices
import SwiftUI

struct SafariDestination: Identifiable, Equatable {
    let id: String
    let url: URL

    init?(urlString: String) {
        guard let url = URL(string: urlString),
              Self.isAllowedWebURL(url) else {
            return nil
        }
        self.url = url
        self.id = url.absoluteString
    }

    init?(url: URL) {
        guard Self.isAllowedWebURL(url) else { return nil }
        self.url = url
        self.id = url.absoluteString
    }

    static func isAllowedWebURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased() else { return false }
        guard scheme == "http" || scheme == "https" else { return false }
        guard let host = url.host, !host.isEmpty else { return false }
        return true
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    final class Coordinator: NSObject, SFSafariViewControllerDelegate {
        private let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            dismiss()
        }
    }
}
