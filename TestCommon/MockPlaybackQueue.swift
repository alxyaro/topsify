// Created by Alex Yaro on 2023-04-20.

@testable import Topsify
import Combine
import CombineExt

final class MockPlaybackQueue: PlaybackQueueType {

    struct State: PlaybackQueueState {
        var history = [PlaybackQueueItem]()
        var activeItem: PlaybackQueueItem?
        var userQueue = [PlaybackQueueItem]()
        var upNext = [PlaybackQueueItem]()
    }

    // MARK: - Interface

    let sourceRelay = CurrentValueRelay<ContentObject?>(nil)
    let stateRelay = CurrentValueRelay<State>(.init())

    let loadWithContentRelay = PassthroughRelay<ContentObject>()
    let loadWithSongsRelay = PassthroughRelay<(songs: [Song], source: ContentObject?)>()
    let addToQueueRelay = PassthroughRelay<Song>()
    let goToNextItemRelay = PassthroughRelay<Void>()
    let goToPreviousItemRelay = PassthroughRelay<Void>()
    let goToItemAtIndexRelay = PassthroughRelay<Int>()

    // MARK: - Mocked Members

    var source: AnyPublisher<ContentObject?, Never> {
        sourceRelay.eraseToAnyPublisher()
    }

    var state: AnyPublisher<State, Never> {
        stateRelay.eraseToAnyPublisher()
    }

    func load(with content: ContentObject) {
        loadWithContentRelay.accept(content)
    }

    func load(with songs: [Song], source: ContentObject?) {
        loadWithSongsRelay.accept((songs, source))
    }

    func addToQueue(_ song: Song) {
        addToQueueRelay.accept(song)
    }

    func goToNextItem() {
        goToNextItemRelay.accept()
    }

    func goToPreviousItem() {
        goToPreviousItemRelay.accept()
    }

    func goToItem(atIndex index: Int) {
        goToItemAtIndexRelay.accept(index)
    }
}
