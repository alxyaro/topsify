// Created by Alex Yaro on 2023-10-11.

extension ButtonVisibility {

    func apply(to button: AppButton, disposeBag: inout DisposeBag) {
        switch self {
        case .shown(let onTap):
            button.isHidden = false
            button.tapPublisher
                .sink(receiveValue: onTap)
                .store(in: &disposeBag)
        case .hidden:
            button.isHidden = true
        }
    }
}
