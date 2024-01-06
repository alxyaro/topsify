// Created by Alex Yaro on 2023-12-31.

import Combine

// Note: this must be a class (not a struct) to prevent simultaneous access crashes.
// For context, see: https://stackoverflow.com/questions/59317936/simultaneous-accesses-when-using-propertywrapper
@propertyWrapper class SubjectBacked<T> {
    private let subject: CurrentValueSubject<T, Never>

    var wrappedValue: T {
        get {
            subject.value
        }
        set {
            subject.value = newValue
        }
    }

    var projectedValue: CurrentValueSubject<T, Never> {
        subject
    }

    init(wrappedValue: T) {
        subject = .init(wrappedValue)
    }
}
