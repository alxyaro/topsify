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

extension ImageProviderType {
    static func createDefault() -> some ImageProviderType {
        MockImageProvider()
    }
}

final class MockImageProvider: ImageProviderType {
    private var cancellables = Set<AnyCancellable>()
    private static var cachedImages = NSCache<NSURL, UIImage>()

    func image(for url: URL) -> AnyPublisher<UIImage, ImageFetchError> {
        return Future { promise in
            if let image = Self.cachedImages.object(forKey: url as NSURL) {
                promise(.success(image))
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0..<1)) {
                let image = UIImage(named: TestImages.getNamedImage(for: url) ?? "")
                guard let image else {
                    promise(.failure(.notFound))
                    return
                }
                Self.cachedImages.setObject(image, forKey: url as NSURL)
                return promise(.success(image))
            }
        }.eraseToAnyPublisher()
    }

    func prefetchImage(for url: URL) {
        image(for: url).ignoreFailure().sink(receiveValue: { _ in }).store(in: &cancellables)
    }
}
