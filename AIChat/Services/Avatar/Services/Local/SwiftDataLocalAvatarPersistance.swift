//
//  SwiftDataLocalAvatarPersistence.swift
//  AIChat
//
//  Created by Michal Fereniec on 30/03/2025.
//
import SwiftUI
import SwiftData

@MainActor
struct SwiftDataLocalAvatarPersistence: LocalAvatarPersistence {

    private let container: ModelContainer // Using ModelContainer is better than @View as u cant test them and they dont work well with architecture
    private var mainContext: ModelContext {
        container.mainContext
    }

    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: AvatarEntity.self) // force unwrapping in this case is rare case of intentional usage of doing so, as we want to immadietely know as soon as we run our app that the container is broken
    }

    func addRecentAvatar(avatar: AvatarModel) throws {
        let entity = AvatarEntity(from: avatar)
        mainContext.insert(entity)
        try mainContext.save()
    }

    func getRecentAvatars() throws -> [AvatarModel] {
        let descriptor = FetchDescriptor<AvatarEntity>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map({ $0.toModel() })
    }
}
