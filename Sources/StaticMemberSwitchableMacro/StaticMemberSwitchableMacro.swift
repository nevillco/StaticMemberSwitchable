public struct StaticMemberSwitchableMacro: MemberMacro {

    public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        let staticProperties = declaration.properties
            .filter { property in
                property.accessLevel >= declaration.declAccessLevel && property.isStatic
            }
        let cases = staticProperties.map(\.identifier.text)
            .map { "case \($0)" }
            .joined(separator: "\n")
        let allStaticMembers: DeclSyntax =
        """
        enum Switchable {
            \(raw: cases)
        }
        var switchable: Switchable { .foo }
        """

        return [allStaticMembers]
    }

}
