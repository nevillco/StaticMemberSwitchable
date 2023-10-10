// MARK: - AccessLevelModifier
enum AccessLevelModifier: String, Comparable, CaseIterable {

    case `private`
    case `fileprivate`
    case `internal`
    case `public`
    case `open`

    var keyword: Keyword {
        switch self {
        case .private: return .private
        case .fileprivate: return .fileprivate
        case .internal: return .internal
        case .public: return .public
        case .open: return .open
        }
    }

    static func <(
        lhs: AccessLevelModifier,
        rhs: AccessLevelModifier
    ) -> Bool {
        let lhs = Self.allCases.firstIndex(of: lhs)!
        let rhs = Self.allCases.firstIndex(of: rhs)!
        return lhs < rhs
    }

}
