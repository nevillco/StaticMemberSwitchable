extension DeclGroupSyntax {

    var identifier: TokenSyntax? {
        return (self as? IdentifiableDeclSyntax)?.identifier
    }

    var properties: [VariableDeclSyntax] {
        memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
    }

}
