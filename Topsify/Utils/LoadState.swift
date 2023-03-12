// Created by Alex Yaro on 2023-02-19.

import Foundation

enum LoadState<E: Error & Equatable>: Equatable {
    case initial
    case loading
    case loaded
    case error(E)

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

    var error: E? {
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
