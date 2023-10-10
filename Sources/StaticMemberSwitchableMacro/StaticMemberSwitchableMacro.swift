public struct StaticMemberSwitchableMacro: MemberMacro {

    public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        let properties = declaration.properties
            .filter { property in
                property.accessLevel >= declaration.declAccessLevel && property.isStatic
            }

        let allStaticMembers: DeclSyntax = 
        """
        \(raw: declaration.declAccessLevel) static var allStaticMembers = [
            \(raw: properties.map(\.identifier.text).joined(separator: ",\n"))
        ]
        """

        return [allStaticMembers]
    }

}
