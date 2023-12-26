// Created by Alex Yaro on 2023-09-29.

@testable import Topsify
import Foundation

extension ContentID {

    static func mock(
        contentType: ContentType = .album,
        id: UUID = .init()
    ) -> Self {
        self.init(contentType: contentType, id: id)
    }
}
