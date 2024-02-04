// Created by Alex Yaro on 2024-02-03.

import Combine

extension Task {
    var anyCancellable: AnyCancellable {
        AnyCancellable(cancel)
    }
}
