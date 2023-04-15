// Created by Alex Yaro on 2023-04-14.

import Foundation

extension PlayerStageView {
    struct ViewModel {

        struct Item {
            let artworkURL: URL
        }

        struct State {
            let items: [Item]
            let activeItemIndex: Int
        }

        /*var state: AnyPublisher<State, Never> {

        }*/

        private let playbackQueue: PlaybackQueue

        init(playbackQueue: PlaybackQueue) {
            self.playbackQueue = playbackQueue
        }

        func movedToItem(atIndex index: Int) {
            
        }
    }
}
