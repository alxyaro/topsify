//
//  API.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-23.
//

import Foundation
import Combine

enum API {
    static let library = LibraryAPI()
    static let account = AccountAPI()
    static let users = UsersAPI()
}
