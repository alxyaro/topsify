//
//  HomeRecentListeningActivityViewModel.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-30.
//

import Foundation
import Combine
import CombineExt

class HomeRecentListeningActivityViewModel {
    private let loadDataRelay = PassthroughRelay<Void>()
    private let cellViewModelsRelay = CurrentValueRelay<[HomeRecentListeningActivityItemViewModel]>([])
    private var cancellables = Set<AnyCancellable>()

    var reloadCells: AnyPublisher<Void, Never> {
        cellViewModelsRelay.mapToVoid().eraseToAnyPublisher()
    }
    var cellViewModels: [HomeRecentListeningActivityItemViewModel] {
        cellViewModelsRelay.value
    }

    init() {
        loadDataRelay
            .map {
                API.account.getRecentListeningActivity().materialize()
            }
            .switchToLatest()
            .values()
            .sink(receiveValue: { [cellViewModelsRelay] recentActivity in
                let viewModels = recentActivity.map {
                    HomeRecentListeningActivityItemViewModel(title: $0.textValue, imageURL: $0.imageURL)
                }
                cellViewModelsRelay.accept(viewModels)
            })
            .store(in: &cancellables)
    }
    
    func loadData() {
        loadDataRelay.accept()
    }
}
