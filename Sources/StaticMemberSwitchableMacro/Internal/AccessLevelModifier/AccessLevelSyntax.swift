// MARK: - AccessLevelSyntax
public protocol AccessLevelSyntax {

    var modifiers: DeclModifierListSyntax { get set }

}

// MARK: - AccessLevelSyntax - Internal
extension AccessLevelSyntax {

    var accessLevel: AccessLevelModifier {
        get {
            modifiers.lazy
                .compactMap { AccessLevelModifier(rawValue: $0.name.text) }
                .first ?? .internal
        }
        set {
            modifiers = modifiers.filter {
                AccessLevelModifier(rawValue: $0.name.text) == nil
            } + [
                DeclModifierSyntax(name: .keyword(newValue.keyword))
            ]
        }
    }

}

// MARK: - AccessLevelSyntax - Conformances
extension StructDeclSyntax: AccessLevelSyntax { }
extension ClassDeclSyntax: AccessLevelSyntax { }
extension EnumDeclSyntax: AccessLevelSyntax { }
extension ActorDeclSyntax: AccessLevelSyntax { }
extension FunctionDeclSyntax: AccessLevelSyntax { }
extension VariableDeclSyntax: AccessLevelSyntax { }
extension DeclGroupSyntax {

    var declAccessLevel: AccessLevelModifier {
        get { (self as? AccessLevelSyntax)?.accessLevel ?? .internal }
    }

}
