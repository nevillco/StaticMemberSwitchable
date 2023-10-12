// MARK: - StaticMemberSwitchableError
public struct StaticMemberSwitchableError: Error {

    public let message: String

    public enum Kind: String {
        case notAStruct
        case noStaticMembersFound
        case noStaticMembersWithAccessLevelFound
        case missingRequiredConformance
    }
    public let kind: Kind

    public init(
        message: String,
        kind: Kind
    ) {
        self.message = message
        self.kind = kind
    }

}

// MARK: - StaticMemberSwitchableError - DiagnosticMessage
extension StaticMemberSwitchableError: DiagnosticMessage {

    public var diagnosticID: SwiftDiagnostics.MessageID {
        .init(
            domain: "StaticMemberSwitchableError",
            id: kind.rawValue
        )
    }
    
    public var severity: SwiftDiagnostics.DiagnosticSeverity {
        .error
    }

}

// MARK: - StaticMemberSwitchableError - Public
public extension StaticMemberSwitchableError {

    func diagnostic(node: SyntaxProtocol) -> DiagnosticsError {
        .init(diagnostics: [
            .init(node: node, message: self),
        ])
    }

}

// MARK: - StaticMemberSwitchableError - Internal
extension StaticMemberSwitchableError {

    static let notAStruct = Self(
        message: "StaticMemberSwitchable only supports struct values.",
        kind: .notAStruct
    )

    static let noStaticMembersFound = Self(
        message: "No static members found in declaration. Make sure the static members are not in a separate extension.",
        kind: .noStaticMembersFound
    )

    static func noStaticMembersFound(
        withAccessLevel accessLevel: AccessLevelModifier
    ) -> Self {
        .init(
            message: "No static members with \(accessLevel.rawValue) access level found. Static members must have at least the same access level as the enclosing type.",
            kind: .noStaticMembersWithAccessLevelFound
        )
    }

    static let missingRequiredConformance = Self(
        message: "Types must conform to either Equatable or Identifiable in the same declaraction that they use @StaticMemberSwitchable.", 
        kind: .missingRequiredConformance
    )

}
