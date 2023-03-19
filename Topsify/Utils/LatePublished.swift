//
//  LatePublished.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-30.
//

import Foundation
import Combine

@propertyWrapper class LatePublished<T> {
    let subject: CurrentValueSubject<T, Never>
    var wrappedValue: T {
        get {
            subject.value
        }
        set {
            subject.send(newValue)
        }
    }
    var projectedValue: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }
    
    init(wrappedValue: T) {
        subject = CurrentValueSubject(wrappedValue)
    }
}
