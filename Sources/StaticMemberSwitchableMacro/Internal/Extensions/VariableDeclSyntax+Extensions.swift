extension VariableDeclSyntax {

    public var isStatic: Bool {
        return modifiers.lazy
            .contains { $0.name.tokenKind == .keyword(.static) }
    }

    public var identifier: TokenSyntax {
        return bindings.lazy
            .compactMap { $0.pattern.as(IdentifierPatternSyntax.self) }
            .first!.identifier
    }

}
