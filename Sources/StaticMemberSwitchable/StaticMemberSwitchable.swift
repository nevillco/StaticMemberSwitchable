@attached(member, names: named(switchable), named(Switchable))
public macro StaticMemberSwitchable() = #externalMacro(
    module: "StaticMemberSwitchableMacro",
    type: "StaticMemberSwitchableMacro"
)
