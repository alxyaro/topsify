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

    let sourceSubject = CurrentValueSubject<ContentObject?, Never>(nil)
    let stateSubject = CurrentValueSubject<State, Never>(.init())

    var stateValue: State {
        get {
            stateSubject.value
        }
        set {
            stateSubject.send(newValue)
        }
    }

    let loadWithContentSubject = PassthroughSubject<ContentObject, Never>()
    let loadWithSongsSubject = PassthroughSubject<(songs: [Song], source: ContentObject?), Never>()
    let addToQueueSubject = PassthroughSubject<Song, Never>()
    let goToNextItemSubject = PassthroughSubject<Void, Never>()
    let goToPreviousItemSubject = PassthroughSubject<Void, Never>()
    let goToItemAtIndexSubject = PassthroughSubject<(index: PlaybackQueueIndex, emptyUserQueueIfUpNextIndex: Bool), Never>()

    // MARK: - Mocked Members

    var source: AnyPublisher<ContentObject?, Never> {
        sourceSubject.eraseToAnyPublisher()
    }

    var stateWithContext: AnyPublisher<StateWithContext, Never> {
        stateSubject.map { (state: $0, context: nil) }.eraseToAnyPublisher()
    }

    func load(with content: ContentObject) {
        loadWithContentSubject.send(content)
    }

    func load(with songs: [Song], source: ContentObject?) {
        loadWithSongsSubject.send((songs, source))
    }

    func addToQueue(_ song: Song) {
        addToQueueSubject.send(song)
    }

    func goToNextItem() {
        goToNextItemSubject.send()
    }

    func goToPreviousItem() {
        goToPreviousItemSubject.send()
    }

    func goToItem(atIndex index: PlaybackQueueIndex, emptyUserQueueIfUpNextIndex: Bool) {
        goToItemAtIndexSubject.send((index: index, emptyUserQueueIfUpNextIndex: emptyUserQueueIfUpNextIndex))
    }
}
