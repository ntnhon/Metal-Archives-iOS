//
//  MultipleChoiceSet.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/12/2022.
//

import Foundation

protocol MultipleChoiceProtocol {
    static var noChoice: String { get }
    static var multipleChoicesSuffix: String { get }
    static var totalChoices: Int { get }
    var choiceDescription: String { get }
}

class MultipleChoiceSet<T: MultipleChoiceProtocol & Equatable> {
    @Published private(set) var choices = [T]()

    var noChoice: Bool { choices.isEmpty }

    var title: String {
        if choices.isEmpty {
            return T.noChoice
        } else if choices.count == 1 {
            return choices.first?.choiceDescription ?? ""
        } else {
            return "\(choices.count) \(T.multipleChoicesSuffix)"
        }
    }

    var detail: String {
        if choices.isEmpty {
            return T.noChoice
        } else if choices.count == 1 {
            return choices.first?.choiceDescription ?? ""
        } else {
            return choices.map { $0.choiceDescription }.joined(separator: ", ")
        }
    }

    func isSelected(_ choice: T) -> Bool {
        choices.contains(choice)
    }

    func select(_ choice: T) {
        if choices.contains(choice) {
            choices.removeAll { $0 == choice }
        } else {
            choices.append(choice)
        }

        if choices.count == T.totalChoices {
            choices.removeAll()
        }
    }

    func deselectAll() {
        choices.removeAll()
    }
}
