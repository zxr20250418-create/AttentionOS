import Foundation
import SwiftData

@Model
final class Case {
    var title: String
    var brief: String
    var details: String
    var importance: Int
    var urgency: Int
    var state: ItemState
    var decision: Decision
    var benefit: Double
    var friction: Double
    var nextReview: Date?
    var notifyEnabled: Bool
    var manual: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Attempt.parentCase)
    var attempts: [Attempt]

    init(
        title: String,
        brief: String = "",
        details: String = "",
        importance: Int = 0,
        urgency: Int = 0,
        state: ItemState = .active,
        decision: Decision = .undecided,
        benefit: Double = 0,
        friction: Double = 0,
        nextReview: Date? = nil,
        notifyEnabled: Bool = false,
        manual: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        attempts: [Attempt] = []
    ) {
        self.title = title
        self.brief = brief
        self.details = details
        self.importance = importance
        self.urgency = urgency
        self.state = state
        self.decision = decision
        self.benefit = benefit
        self.friction = friction
        self.nextReview = nextReview
        self.notifyEnabled = notifyEnabled
        self.manual = manual
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.attempts = attempts
    }
}
