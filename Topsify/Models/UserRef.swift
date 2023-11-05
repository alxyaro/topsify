// Created by Alex Yaro on 2023-11-05.

import Foundation

struct UserRef: Identifiable, Equatable {
    let id: UUID
    let avatarURL: URL
    let name: String
}
