// MARK: - StaticMemberSwitchableError
public struct StaticMemberSwitchableError: Error {

    public let message: String

    public enum Kind: String {
        case notAStruct
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

    static let missingRequiredConformance = Self(
        message: "StaticMemberSwitchable requires types conform to either Identifiable or Equatable.", 
        kind: .missingRequiredConformance
    )

}
