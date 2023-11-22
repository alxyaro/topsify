// Created by Alex Yaro on 2023-11-11.

struct Identified<Value, ID: Hashable>: Identifiable {
    let id: ID
    let value: Value
}
