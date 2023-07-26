// Created by Alex Yaro on 2023-07-21.

import Combine
import Foundation

protocol QueueSelectionMenuViewModelDelegate: AnyObject {
    func selectionMenuRemoveButtonTapped()
    func selectionMenuMoveToQueueButtonTapped()
}

final class QueueSelectionMenuViewModel {
    private let dependencies: Dependencies
    private weak var delegate: QueueSelectionMenuViewModelDelegate?
    private var disposeBag = DisposeBag()

    init(
        dependencies: Dependencies,
        delegate: QueueSelectionMenuViewModelDelegate
    ) {
        self.dependencies = dependencies
        self.delegate = delegate
    }

    func bind(inputs: Inputs) -> Outputs {
        inputs.tappedRemoveButton
            .sink { [weak delegate] in
                delegate?.selectionMenuRemoveButtonTapped()
            }
            .store(in: &disposeBag)

        inputs.tappedMoveToQueueButton
            .sink { [weak delegate] in
                delegate?.selectionMenuMoveToQueueButtonTapped()
            }
            .store(in: &disposeBag)

        return Outputs(
            showMoveToQueueButton: dependencies.isQueueItemSelected
                .map(!)
                .eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension QueueSelectionMenuViewModel {

    struct Dependencies {
        let isQueueItemSelected: AnyPublisher<Bool, Never>
    }

    struct Inputs {
        let tappedRemoveButton: AnyPublisher<Void, Never>
        let tappedMoveToQueueButton: AnyPublisher<Void, Never>
    }

    struct Outputs {
        let showMoveToQueueButton: AnyPublisher<Bool, Never>
    }
}
