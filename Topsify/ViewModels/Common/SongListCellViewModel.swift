// Created by Alex Yaro on 2023-07-11.

import Combine
import Foundation

final class SongListCellViewModel {
    private let song: Song
    private let optionsButtonState: ButtonState

    private var disposeBag = DisposeBag()

    init(
        song: Song,
        optionsButtonState: ButtonState = .hidden
    ) {
        self.song = song
        self.optionsButtonState = optionsButtonState
    }

    func bind(inputs: Inputs) -> Outputs {
        disposeBag = .init()

        if case .shown(let tapHandler) = optionsButtonState {
            inputs.tappedOptionsButton
                .sink(receiveValue: tapHandler)
                .store(in: &disposeBag)
        }

        return Outputs(
            artworkURL: song.imageURL,
            title: song.title,
            subtitle: song.artists.map(\.name).commaJoined(),
            showExplicitLabel: song.isExplicit,
            showOptionsButton: optionsButtonState.isShown
        )
    }
}

// MARK: - Nested Types

extension SongListCellViewModel {

    struct Inputs {
        let tappedOptionsButton: AnyPublisher<Void, Never>
    }

    struct Outputs {
        let artworkURL: URL
        let title: String
        let subtitle: String
        let showExplicitLabel: Bool
        let showOptionsButton: Bool
    }

    enum ButtonState {
        case hidden
        case shown(tapHandler: () -> Void)

        var isShown: Bool {
            switch self {
            case .shown: return true
            default: return false
            }
        }
    }
}
