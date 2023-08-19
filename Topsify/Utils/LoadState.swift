// Created by Alex Yaro on 2023-02-19.

import Foundation

enum LoadState<ErrorType: Error> {
    case initial
    case loading
    case loaded
    case error(ErrorType)

    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }

    var isLoaded: Bool {
        switch self {
        case .loaded:
            return true
        default:
            return false
        }
    }

    var isError: Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }

    var error: ErrorType? {
        switch self {
        case let .error(error):
            return error
        default:
            return nil
        }
    }

    static func + (lhs: LoadState, rhs: LoadState) -> LoadState {
        [lhs, rhs].combined()
    }
}

extension LoadState: Equatable where ErrorType: Equatable {}

extension LoadState: CustomDebugStringConvertible {

    var debugDescription: String {
        switch self {
        case .initial:
            return "\(LoadState.self).initial"
        case .loading:
            return "\(LoadState.self).loading"
        case .loaded:
            return "\(LoadState.self).loaded"
        case .error(let error):
            return "\(LoadState.self).error(\(error))"
        }
    }
}

extension Array {
    func combined<E>() -> LoadState<E> where Element == LoadState<E> {
        if let element = first(where: \.isError), let error = element.error {
            return .error(error)
        } else if contains(where: \.isLoading) {
            return .loading
        } else {
            return .loaded
        }
    }
}
