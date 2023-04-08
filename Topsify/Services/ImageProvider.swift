//  Created by Alex Yaro on 2022-04-30.

import UIKit
import Combine

enum ImageFetchError: Error {
    case notFound
}

protocol ImageProviderType {
    func image(for url: URL) -> AnyPublisher<UIImage, ImageFetchError>
    func prefetchImage(for url: URL)
}

typealias ImageProvider = FakeImageProvider
