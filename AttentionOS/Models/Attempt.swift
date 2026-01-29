import Foundation
import SwiftData

@Model
final class Attempt {
    var note: String
    var outcome: String
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

    var parentCase: Case?

    init(
        note: String,
        outcome: String = "",
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
        parentCase: Case? = nil
    ) {
        self.note = note
        self.outcome = outcome
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
        self.parentCase = parentCase
    }
}
