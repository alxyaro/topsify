// Created by Alex Yaro on 2023-08-19.

import UIKit

extension NSDiffableDataSourceSnapshot where ItemIdentifierType == AnyHashable {

    /// An item ID that's unique compared to all other item IDs in the snapshot.
    private struct UniqueItemID<SectionIdentifierType: Hashable>: Hashable {
        let sectionID: SectionIdentifierType
        let id = UUID()
    }

    /// Reloads and replaces the given section with random item IDs, totaling the `itemCount`.
    /// This is useful for sections that don't need the diffable behaviour and are configured strictly based on the IndexPath.
    mutating func reloadIDIndependentSection(_ sectionID: SectionIdentifierType, itemCount: Int) {
        let newIdentifiers = Array(repeating: (), count: itemCount).map { UniqueItemID(sectionID: sectionID) }
        replaceSectionItems(inSection: sectionID, with: newIdentifiers)
        reloadSections([sectionID])
    }

    mutating func replaceSectionItems(inSection sectionID: SectionIdentifierType, with newIdentifiers: [ItemIdentifierType]) {
        deleteItems(itemIdentifiers(inSection: sectionID))
        appendItems(newIdentifiers, toSection: sectionID)
    }
}
