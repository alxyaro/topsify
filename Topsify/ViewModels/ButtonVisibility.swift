// Created by Alex Yaro on 2023-10-11.

enum ButtonVisibility: Equatable {
    case shown(onTap: () -> Void)
    case hidden

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.shown, .shown), (.hidden, .hidden):
            return true
        case (.hidden, _), (.shown, _):
            return false
        }
    }
}
