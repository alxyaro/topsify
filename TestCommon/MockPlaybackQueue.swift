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

        var context: PlaybackQueueStateContext?
    }

    // MARK: - Interface

    let sourceSubject = CurrentValueSubject<PlaybackSource?, Never>(nil)
    let stateSubject = CurrentValueSubject<State, Never>(.init())

    var stateValue: State {
        get {
            stateSubject.value
        }
        set {
            stateSubject.send(newValue)
        }
    }

    let loadWithSongsSubject = PassthroughSubject<(songs: [Song], source: PlaybackSource?), Never>()
    let addToQueueSubject = PassthroughSubject<Song, Never>()
    let goToNextItemSubject = PassthroughSubject<Void, Never>()
    let goToPreviousItemSubject = PassthroughSubject<Void, Never>()
    let goToItemAtIndexSubject = PassthroughSubject<(index: PlaybackQueueIndex, emptyUserQueueIfUpNextIndex: Bool), Never>()
    var moveItemFromToCallback: (PlaybackQueueIndex, PlaybackQueueIndex) -> Bool = { _, _ in false }
    var moveItemsToQueueAtSubject = PassthroughSubject<[PlaybackQueueIndex], Never>()
    var removeItemsAtSubject = PassthroughSubject<[PlaybackQueueIndex], Never>()

    // MARK: - Mocked Members

    var source: AnyPublisher<PlaybackSource?, Never> {
        sourceSubject.eraseToAnyPublisher()
    }

    var stateWithContext: AnyPublisher<StateWithContext, Never> {
        stateSubject.map { (state: $0, context: $0.context) }.eraseToAnyPublisher()
    }

    func load(with songs: [Song], source: PlaybackSource?) {
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

    func moveItem(from fromIndex: PlaybackQueueIndex, to toIndex: PlaybackQueueIndex) -> Bool {
        moveItemFromToCallback(fromIndex, toIndex)
    }

    func moveItemsToQueue(at indices: [PlaybackQueueIndex]) {
        moveItemsToQueueAtSubject.send(indices)
    }

    func removeItems(at indices: [PlaybackQueueIndex]) {
        removeItemsAtSubject.send(indices)
    }
}
