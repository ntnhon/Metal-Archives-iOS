//
//  Question.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/04/2024.
//

import Foundation

public enum Question: Sendable, CaseIterable {
    case error429
    case designer
    case developer
    case whoAmI

    // swiftlint:disable line_length
    public var title: String {
        switch self {
        case .error429:
            "You used to encounter 429 errors with previous versions. Where are they now? And sometimes the app is a bit slow. Why is it?"
        case .designer:
            "You are a designer and want to contribute to the design of this app. What and how can you do?"
        case .developer:
            "You are a developer and want to contribute. What and how can you do?"
        case .whoAmI:
            "Who am I?"
        }
    }

    public var description: String {
        switch self {
        case .error429:
            "Metal Archives server recently introduced a request limit based on IP addresses to reduce load. As the app is making a lot of requests under the hood, especially for requesting thumbnails, there are high chances that you're temporarily blocked. While the block is temporary and you can retry after several seconds, it's still frustrating. I implemented an auto-retry mechanism so you don't have to retry yourself. So when something is taking time to load, it's because you're being blocked and the app is waiting for another retry. Just wait, and everything's fine."

        case .designer:
            "While I'm open to contributions, changing design usually takes time, especially when it's a big change. So use your best guess to propose small changes that are doable in small iterations. With that being said, you are always welcome to propose as many app icons as possible as it takes virtually no time to add. Drop me an email."

        case .developer:
            "This app is native and done in SwiftUI. If you happen to also do SwiftUI and want to contribute, please open an issue on GitHub to discuss what you want to do so we're on the same page before you can commit to it."

        case .whoAmI:
            "A software engineer who happens to love music in general and metal in particular. I love making good quality native mobile applications."
        }
    }
    // swiftlint:enable line_length
}
