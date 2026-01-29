import Foundation
import SwiftData

@Model
final class InboxItem {
    var thought: String
    var why: String
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

    init(
        thought: String,
        why: String = "",
        importance: Int = 0,
        urgency: Int = 0,
        state: ItemState = .inbox,
        decision: Decision = .undecided,
        benefit: Double = 0,
        friction: Double = 0,
        nextReview: Date? = nil,
        notifyEnabled: Bool = false,
        manual: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.thought = thought
        self.why = why
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
    }
}
