import Foundation

enum ItemState: String, Codable, CaseIterable {
    case inbox
    case active
    case paused
    case done
}

enum Decision: String, Codable, CaseIterable {
    case undecided
    case doNow
    case schedule
    case delegate
    case drop
}
