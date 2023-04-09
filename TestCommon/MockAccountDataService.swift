// Created by Alex Yaro on 2023-02-19.

@testable import Topsify
import Foundation
import Combine
import CombineSchedulers

public struct MockAccountDataService: AccountDataServiceType {
    var recentActivityPublisher: AnyPublisher<[ContentObject], Error> = .just([])

    public func recentActivity() -> Future<[ContentObject], Error> {
        recentActivityPublisher.toFuture()
    }
}
