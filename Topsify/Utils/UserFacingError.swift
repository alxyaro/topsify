// Created by Alex Yaro on 2023-08-18.

import Foundation

protocol UserFacingError: Error, Equatable, LocalizedError {
    var message: String { get }
}

extension UserFacingError {
    var errorDescription: String? {
        message
    }
}
