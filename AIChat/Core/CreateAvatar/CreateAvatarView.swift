//
//  CreateAvatarView.swift
//  AIChat
//
//  Created by Michal Fereniec on 19/02/2025.
//

import SwiftUI

@Observable
@MainActor
class CreateAvatarViewModel {
    let authManager: AuthManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let logManager: LogManager
    
    private(set) var isGenerating: Bool = false
    private(set) var generatedImage: UIImage?
    private(set) var isSaving: Bool = false
    
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    var avatarName: String = ""
    var showAlert: AnyAppAlert?

    init(authManager: AuthManager, aiManager: AIManager, avatarManager: AvatarManager, logManager: LogManager) {
        self.authManager = authManager
        self.aiManager = aiManager
        self.avatarManager = avatarManager
        self.logManager = logManager
        }
    
    func onBackButtonPressed(onDismiss: () -> Void) {
        logManager.trackEvent(event: Event.backButtonPressed)
        onDismiss()
    }

    func onGenerateImagePressed() {
        logManager.trackEvent(event: Event.generateImageStart)
        isGenerating = true

        Task {
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                let prompt = avatarDescriptionBuilder.characterDescription

                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuilder: avatarDescriptionBuilder))
            } catch {
                logManager.trackEvent(event: Event.generateImageFail(error: error))
            }

            isGenerating = false
        }
    }

    func onSavePressed(onDismiss: @escaping () -> Void) {
        logManager.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return } // this should never fail

        isSaving = true

        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName, minimumCharacterCount: 3)
                let uid = try authManager.getAuthId()

                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: uid
                )

                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)

                // Dismiss screen
                onDismiss()
                logManager.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))
            } catch {
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
            }
            isSaving = false
        }
    }
    
    enum Event: LoggableEvent {
        case backButtonPressed
        case generateImageStart
        case generateImageSuccess(avatarDescriptionBuilder: AvatarDescriptionBuilder)
        case generateImageFail(error: Error)
        case saveAvatarStart
        case saveAvatarSuccess(avatar: AvatarModel)
        case saveAvatarFail(error: Error)
        
        var eventName: String {
            switch self {
            case .backButtonPressed:         return "CreateAvatarView_BackButton_Pressed"
            case .generateImageStart:        return "CreateAvatarView_GenerateImage_Start"
            case .generateImageSuccess:      return "CreateAvatarView_GenerateImage_Success"
            case .generateImageFail:         return "CreateAvatarView_GenerateImage_Fail"
            case .saveAvatarStart:           return "CreateAvatarView_SaveAvatar_Start"
            case .saveAvatarSuccess:         return "CreateAvatarView_SaveAvatar_Success"
            case .saveAvatarFail:            return "CreateAvatarView_SaveAvatar_Fail"
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case .saveAvatarFail(error: let error), .generateImageFail(error: let error):
                return error.eventParameters
            case .generateImageSuccess(avatarDescriptionBuilder: let avatarDescriptionBuilder):
                return avatarDescriptionBuilder.eventParameters
            case .saveAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .generateImageFail:
                return .severe
            case .saveAvatarFail:
                return .warning
            default:
                return .analytic
            }
        }
    }
    
}

struct CreateAvatarView: View {

    @Environment(\.dismiss) private var dismiss

    @State var viewModel: CreateAvatarViewModel

    var body: some View {
        NavigationStack {
            List {
                nameSection
                attributesSection
                imageSection
                saveSection
            }
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .screenAppearAnalytics(name: "CreateAvatarView")
        }
    }

    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                viewModel.onBackButtonPressed(onDismiss: {
                    dismiss()
                })
            }
    }

    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $viewModel.avatarName)
        } header: {
            Text("Name your avatar*")
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }

    private var attributesSection: some View {
        Section {
            VStack(spacing: 4) {
                Picker(selection: $viewModel.characterOption) {
                    ForEach(CharacterOption.allCases, id: \.self) { option in
                        Text(option.rawValue.capitalized)
                            .tag(option)
                    }
                } label: {
                    Text("is a...")
                }

                Picker(selection: $viewModel.characterAction) {
                    ForEach(CharacterAction.allCases, id: \.self) { option in
                        Text(option.rawValue.capitalized)
                            .tag(option)
                    }
                } label: {
                    Text("that is...")
                }

                Picker(selection: $viewModel.characterLocation) {
                    ForEach(CharacterLocation.allCases, id: \.self) { option in
                        Text(option.rawValue.capitalized)
                            .tag(option)
                    }
                } label: {
                    Text("in the...")
                }
            }
        } header: {
            Text("Attributes")
        }
    }

    private var imageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Text("Generate image")
                        .underline()
                        .foregroundStyle(.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .anyButton(.plain) {
                            viewModel.onGenerateImagePressed()
                        }
                        .opacity(viewModel.isGenerating ? 0 : 1)

                    ProgressView()
                        .tint(.accent)
                        .opacity(viewModel.isGenerating ? 1 : 0)
                }
                .disabled(viewModel.isGenerating || viewModel.avatarName.isEmpty)

                Circle()
                    .fill(Color.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage = viewModel.generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    }
                    .clipShape(Circle())
                    .frame(maxWidth: .infinity, maxHeight: 400)
            }
        }
        .removeListRowFormatting()
    }

    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: viewModel.isSaving,
                title: "Save",
                action: {
                    viewModel.onSavePressed(onDismiss: {
                        dismiss()
                    })
                }
            )
            .removeListRowFormatting()
            .padding(.top, 24)
            .opacity(viewModel.generatedImage == nil ? 0.5 : 1.0)
            .disabled(viewModel.generatedImage == nil)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    CreateAvatarView(
        viewModel: CreateAvatarViewModel(
            authManager: DevPreview.shared.authManager,
            aiManager: DevPreview.shared.aiManager,
            avatarManager: DevPreview.shared.avatarManager,
            logManager: DevPreview.shared.logManager
        )
    )
    .previewEnvironment()
}
