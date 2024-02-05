// Created by Alex Yaro on 2024-02-04.

import Foundation

/// A utility to help manage the queue list of a `QueuePlayerType` with identifiable current & next items.
/// If the passed identifiable is already in the desired queue position, no new `QueuePlayerType.Item` will be created.
final class QueuePlayerQueuingHelper {

    struct ItemIdentifier: Hashable {
        let id: UUID
        let url: URL
    }

    private let queuePlayer: any QueuePlayerType
    private var playerItemsToIdentifiers = [AnyHashable: ItemIdentifier]()
    private var disposeBag = DisposeBag()

    init(queuePlayer: some QueuePlayerType) {
        self.queuePlayer = queuePlayer

        queuePlayer.currentItemPublisher
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    // Clean/purge `playerItemsToIdentifiers` whenever currentItem changes
                    self?.cleanIdentifiersDictionary(queuePlayer: queuePlayer)
                }
            }
            .store(in: &disposeBag)
    }

    func setCurrentItem(_ id: ItemIdentifier?) {
        setCurrentItem(id, queuePlayer: queuePlayer)
    }

    func setNextItem(_ id: ItemIdentifier?) {
        setNextItem(id, queuePlayer: queuePlayer)
    }

    private func setCurrentItem(_ id: ItemIdentifier?, queuePlayer: some QueuePlayerType) {
        guard let id else {
            queuePlayer.advanceToNextItem()
            return
        }

        if
            let currentItem = queuePlayer.currentItem,
            let identifier = playerItemsToIdentifiers[AnyHashable(currentItem)],
            id == identifier
        {
            return // no-op; current item matches identifier
        }

        let newCurrentItem = type(of: queuePlayer).Item(url: id.url)
        queuePlayer.replaceCurrentItem(with: newCurrentItem)
        Task { await queuePlayer.seek(to: .zero) }

        associateIdentifier(id, with: newCurrentItem, queuePlayer: queuePlayer)
    }

    private func setNextItem(_ id: ItemIdentifier?, queuePlayer: some QueuePlayerType) {
        guard let currentItem = queuePlayer.currentItem else {
            return // no-op; no current item
        }

        let nextItem = queuePlayer.items()[safe: 1]

        guard let id else {
            if let nextItem {
                queuePlayer.remove(nextItem)
            }
            return
        }

        if
            let nextItem,
            let identifier = playerItemsToIdentifiers[AnyHashable(nextItem)],
            id == identifier
        {
            return // no-op; next item matches identifier
        }

        if let nextItem {
            queuePlayer.remove(nextItem)
        }

        let newNextItem = type(of: queuePlayer).Item(url: id.url)
        queuePlayer.insert(newNextItem, after: currentItem)

        associateIdentifier(id, with: newNextItem, queuePlayer: queuePlayer)
    }

    private func associateIdentifier<Q: QueuePlayerType>(_ id: ItemIdentifier, with item: Q.Item, queuePlayer: Q) {
        playerItemsToIdentifiers[item] = id
        cleanIdentifiersDictionary(queuePlayer: queuePlayer)
    }

    private func cleanIdentifiersDictionary(queuePlayer: some QueuePlayerType) {
        let validPlayerItems = Set<AnyHashable>([queuePlayer.currentItem, queuePlayer.items()[safe: 1]].compactMap { $0 })
        for playerItem in playerItemsToIdentifiers.keys {
            if !validPlayerItems.contains(playerItem) {
                playerItemsToIdentifiers[playerItem] = nil
            }
        }
    }
}

extension QueuePlayerQueuingHelper.ItemIdentifier {

    init?(from item: PlaybackQueueItem?) {
        guard let item else { return nil }
        id = item.id
        url = item.song.streamURL
    }
}
