# `StaticMemberSwitchable`

`StaticMemberSwitchable` is a Swift Macro that provides a way to _exhaustively switch over a type with static members_.

## Motivation

In Swift, it’s not uncommon to find code with this shape:

```swift
struct BasketballTeam: Equatable {
    let name: String
    let primaryColor: Color
    // other properties…
    
    static let celtics = BasketballTeam(
        // …
    )
    
    static let nuggets = BasketballTeam(
        // …
    )
        
    // other instances…
}
```
in other words, a data type with lots of `static` members. 

These values can also be represented as an `enum`, but there are [various tradeoffs](https://www.connorneville.com/blog/my-favorite-macro-use-case-staticmemberiterable) to that. Defining property values (like `name` and `primaryColor` above) requires a bunch of `switch`es all over the place, and adding a new `BasketballTeam` instance requires adding a case to each `switch` throughout the codebase:

```swift
// If we wrote this type as an enum instead:
enum BasketballTeam: Equatable {
    case celtics
    case nuggets
    
    // Switches everywhere!
    var name: String {
        switch self {
        case .celtics: // …
        case .nuggets: // …
        }
    }
    
    var primaryColor: Color {
        switch self {
        // The various properties for .celtics etc
        // are distributed all over the place.
        case .celtics: // …
        case .nuggets: // …
        }
    }
    
    // If we provide custom init behavior,
    // no way to prevent callers from just using
    // a `case` instead:
    
    // init(city: // …
}
```

While a struct may be preferable to an enum when it comes to the above tradeoffs, structs with static members lose in one key area: **exhaustive switching.** Consider the below example that takes our struct instance as a parameter to build a localized string:

```swift
// We’d actually be better off with an enum here, because
// we wouldn’t need a `default`!

func marketingTagline(team: BasketballTeam) -> String {
    switch team {
    case .celtics:
        return // …
    case .nuggets:
        return // …
    // other cases…
    default: fatalError()
    }
}
```

This will work - except until someone adds a new static instance to `BasketballTeam`! The above function will happily compile, and `fatalError()` once called with the new value.

`StaticMemberSwitchable` extends the above example code like so:

```swift
@StaticMemberSwitchable struct BasketballTeam: Equatable {
    let name: String
    let primaryColor: Color
    
    static let celtics = BasketballTeam(
        // …
    )
    
    static let nuggets = BasketballTeam(
        // …
    )
    
    // Macro-generated code:
    
    enum StaticMemberSwitchable {
        case celtics
        case nuggets
    }
    var switchable: StaticMemberSwitchable {
        switch self {
            case .celtics: return .celtics
            case .nuggets: return .nuggets
            default: fatalError()
        }
    }
    
}
```

Which means that callsites can exhaustively switch over the various static members - and get compile-time warnings when new members get added:

```swift
func marketingTagline(team: BasketballTeam) -> String {
    // Now switching over a nice, simple enum with 2 cases
    switch team.switchable {
    case .celtics:
        return // …
    case .nuggets:
        return // …
    }
}
```

## Usage

`StaticMemberSwitchable` is integrated as a Swift package.

### Requirements

* `StaticMemberSwitchable` can currently only be attached to `struct` types. The macro implementation in theory could be extended to support `class` and `enum` types with static members - PRs are welcome.
* `StaticMemberSwitchable` requires a way of uniquely identifying each static member and associating it with a `switch` case. For this purpose, the annotated struct must either be `Identifiable` or `Equatable`. The macro will fail to compile if that is not the case.
* Swift macros currently only have visibility into the declaration they are attached to, so the `: Identifiable` or `: Equatable` conformance must be declared in the same spot that the `@StaticMemberSwitchable` macro is attached.

# `Equatable` and `Identifiable` Values

`StaticMemberSwitchable` requires some way of _matching_ a `static` instance of your type with its macro-generated `case` value. The library supports 2 different implementations depending on if the adopting type is `Equatable` or `Identifiable`.

 If the type adopting `StaticMemberSwitchable` is `Identifiable`, the matching will be done by via the static member’s `id`. If the type adopting `StaticMemberSwitchable` is `Equatable`, the matching will be done via the static member’s `==` `Equatable` implementation.

 The `Identifiable` macro implementation takes precedence over the `Equatable` implementation, because with the former, a caller only needs the `id` of the value to exhaustively switch over static members (rather than an entire instance). For `Identifiable` types, the `StaticMemberSwitchable` macro provides this additional function:

 ```swift
 static func switchable(id: ID) -> StaticMemberSwitchable
 ```

See the [example target](./Sources/StaticMemberSwitchableExample) for example usage.
