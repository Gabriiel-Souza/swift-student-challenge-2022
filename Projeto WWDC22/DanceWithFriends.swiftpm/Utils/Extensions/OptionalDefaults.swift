//
//  OptionalDefaults.swift
//  DanceWithFriends
//
//  Created by Gabriel Souza de Araujo on 10/04/22.
//

import UIKit

extension Optional where Wrapped == CGFloat {
    var orDefault: CGFloat {
        switch self {
        case .none:
            return 0
        case .some(let value):
            return value
        }
    }
}

extension Optional where Wrapped == Int {
    var orDefault: Int {
        switch self {
        case .none:
            return 0
        case .some(let value):
            return value
        }
    }
}

extension Optional where Wrapped == String {
    var orDefault: String {
        switch self {
        case .none:
            return ""
        case .some(let value):
            return value
        }
    }
}

extension Optional where Wrapped == UIFont {
    var orDefault: UIFont {
        switch self {
        case .none:
            return UIFont.systemFont(ofSize: 14, weight: .bold)
        case .some(let value):
            return value
        }
    }
}
