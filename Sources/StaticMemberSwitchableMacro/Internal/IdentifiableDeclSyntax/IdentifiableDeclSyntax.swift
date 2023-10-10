// MARK: - IdentifiableDeclSyntax
protocol IdentifiableDeclSyntax {

    var identifier: TokenSyntax { get }

}

// MARK: - IdentifiableDeclSyntax - Conformances
extension StructDeclSyntax: IdentifiableDeclSyntax { }
extension ClassDeclSyntax: IdentifiableDeclSyntax { }
extension EnumDeclSyntax: IdentifiableDeclSyntax { }
extension ActorDeclSyntax: IdentifiableDeclSyntax { }
extension VariableDeclSyntax: IdentifiableDeclSyntax { }
