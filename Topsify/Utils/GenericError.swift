// Created by Alex Yaro on 2023-02-20.

import Foundation

struct GenericError: Error, Equatable {
    static var defaultMessage = NSLocalizedString("An unknown error occurred, please try again.", comment: "Generic error message")
    var message: String = defaultMessage
}

extension GenericError: LocalizedError {
    var errorDescription: String? {
        message
    }
}
