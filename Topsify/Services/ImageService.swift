//
//  ImageService.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-30.
//

import UIKit
import Combine

enum ImageService {
    
    enum ImageSize {
        case small, medium, large
    }
    enum FetchError: Error {
        case notFound
    }
    
    static func fetchImage(id: UUID, ofSize size: ImageSize = .large) -> AnyPublisher<UIImage, FetchError> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0..<1)) {
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
