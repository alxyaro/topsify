//
//  ImageService.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-30.
//

import UIKit
import Combine

class ImageService {
    private static var cachedImageIds = Set<UUID>()
    
    enum ImageSize {
        case small, medium, large
    }
    enum FetchError: Error {
        case notFound
    }
    
    static func fetchImage(id: UUID, ofSize size: ImageSize = .large) -> AnyPublisher<UIImage, FetchError> {
        return Future { promise in
            let delay = cachedImageIds.contains(id) ? 0 : Double.random(in: 0..<1)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                cachedImageIds.insert(id)
                let image = UIImage(named: TestImages.idsToNames[id] ?? "")
                guard let image = image else {
                    promise(.failure(.notFound))
                    return
                }
                return promise(.success(image))
            }
        }.eraseToAnyPublisher()
    }
}
