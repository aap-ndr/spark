//
//  CircleDestination.swift
//  Spark
//
//  Purpose:
//  Circle-specific navigation destination wiring.
//
//  Responsibilities:
//  • Hosts circle detail routing from the circle feature.
//

import Foundation

struct CircleDestination: Hashable, Identifiable {
    let circleID: String

    var id: String { circleID }
}
