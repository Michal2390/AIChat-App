//
//  ABTestService.swift
//  AIChat
//
//  Created by Michal Fereniec on 08/08/2025.
//
import SwiftUI

@MainActor
protocol ABTestService {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
    func fetchUpdatedConfig() async throws -> ActiveABTests
}
