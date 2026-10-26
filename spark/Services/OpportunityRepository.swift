//
//  OpportunityRepository.swift
//  Spark
//
//  Purpose:
//  Opportunity feed loading abstraction.
//
//  Responsibilities:
//  • Serves bundled opportunity seed data to the UI.
//

import Foundation

protocol OpportunityRepositoryProtocol {
    func fetchOpportunities() async -> [Opportunity]
}

/// Loads bundled opportunity seed data with a short simulated network delay.
final class LocalOpportunityRepository: OpportunityRepositoryProtocol {
    func fetchOpportunities() async -> [Opportunity] {
        try? await Task.sleep(nanoseconds: 450_000_000)
        return OpportunityContent.seed
    }
}
