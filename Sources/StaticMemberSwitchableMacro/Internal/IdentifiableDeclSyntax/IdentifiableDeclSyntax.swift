protocol IdentifiableDeclSyntax {

    var identifier: TokenSyntax { get }

}

extension StructDeclSyntax: IdentifiableDeclSyntax { }
extension ClassDeclSyntax: IdentifiableDeclSyntax { }
extension EnumDeclSyntax: IdentifiableDeclSyntax { }
extension ActorDeclSyntax: IdentifiableDeclSyntax { }
extension VariableDeclSyntax: IdentifiableDeclSyntax { }
