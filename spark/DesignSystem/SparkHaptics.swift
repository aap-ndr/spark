//
//  SparkHaptics.swift
//  Spark
//
//  Purpose:
//  Haptic feedback helpers for user interactions.
//
//  Responsibilities:
//  • Wraps common UIKit haptic patterns used throughout Spark.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum SparkHaptics {
    static func lightImpact() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    static func mediumImpact() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    static func successNotification() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        #endif
    }

    static func heavyImpact() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
}
