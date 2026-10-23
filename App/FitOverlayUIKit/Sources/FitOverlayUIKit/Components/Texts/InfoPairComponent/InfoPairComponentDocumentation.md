# InfoPairComponent

## Overview
<!-- Give a reason behind this component & what it is doing -->
The InfoPairComponent functions as an information excerpt to be displayed to the user. This component will have many varients which will represent many variations of this component, including username bio, title variants and more!

The `InfoPairComponent` is a foundational component used to create info pairs which consists of a title & subtext components. This component has many varients, allowing you to effectively create any style of `InfoPair` you could possibly want. FitOverlayUIKit extends the InfoPair component on many occasions to create more specialized implementations.

## Design
LINK: [FIGMA](https://www.figma.com/design/x5MkR0UFRMUkp0eiAXVbmy/FitOverlayUIKit)

## Usage
<!-- Explain how to use the component here -->
<!-- Ensure to provide at-least one example per initializer to make the user understand the scope of the component -->
<!-- Add one image per initializer (This is UI after all) -->
The `InfoPair` component keps customisability in mind, hence the initialisers being flexible by allowing direct input, or via an externally managed observable object named `InfoPairComponentConfig`

### Example: All defaults
The default initializer has default values for both the title and subtext parts of this component, so be careful!
```swift
InfoPairComponent()
```

### Example: Externally managed config
This allows you to have an external config which can be modified from the outside, useful for setting default properties or extending this component.

The config is optional (has a default value), and you can also pass in `title` and `description` params into this component if you want to use the simple implementation!
```swift
InfoPairComponent(config: .init())
```

> [!NOTE]
> Each of these initializers allows you to pass a closure named `onSelfAppear` which exposes the config used on the inside (works with an external config as well). To allow for code execution & component customization!
```swift
InfoPairComponent(...) { config in
    print("do something with me \(config)")
}
```

## Props/Parameters
| Property | Type | Description |
|----------|------|-------------|
| `config` | InfoPairComponentConfig? | Configuration for the component. |
| `title` | string? | The title for the component |
| `description` | string? | The description for the component |
| `onSelfAppear` | ((InfoPairComponentConfig) -> ())? | A closure to execute any code / modify the component |

## Guidelines
<!-- Explain when and when not to use the component based on past experience -->
- **When to Use**: This component should only be used when the text hierarchy could be maintained.

## Customization
<!-- Explain how users can customize the component via the "Config" object in InfoPairComponentConfig Struct -->
This component can be customised via the `InfoPairComponentConfig`.

## InfoPairComponentConfig

The `InfoPairComponentConfig` class is a key part of customizing the `InfoPairComponent`. It defines the appearance and behavior of the information pair, allowing for flexible and consistent styling across your application.

### Overview
The `InfoPairComponentConfig` class conforms to `ObservableObject` and is typically used with the `@StateObject` or `@ObservedObject` property wrapper in SwiftUI to manage the component's state. The class contains several published properties that allow you to adjust key aspects of the information pair's presentation.

### Properties

| Property      | Type                | Description |
|--------------|---------------------|-------------|
| `title`      | `String`            | The primary text or title of the information pair. Defaults to "Enter a title here". |
| `description`| `String`            | The secondary text or description of the information pair. Defaults to "Enter a 3 line / 2 line description here". |
| `variant`    | `InfoPairVariants`  | Defines the visual variant of the information pair. Currently supports `.generic` variant. |

### Example: Customizing InfoPair Appearance
You can modify the `InfoPairComponentConfig` to change the information pair's content and appearance:

```swift
@StateObject public var infoPairConfig = InfoPairComponentConfig()

InfoPairComponent(config: infoPairConfig)
.onAppear {
    // Customize the info pair's configuration
    infoPairConfig.title = "User Profile"
    infoPairConfig.description = "Software engineer passionate about creating intuitive user interfaces"
}
```

### Example: Using InfoPairComponentConfig Directly
Here's an example of creating an InfoPairComponent with a custom configuration:

```swift
InfoPairComponent(
    title: "Project Details", 
    description: "A comprehensive project management tool designed to streamline team collaboration"
)
```

### Example: Modifying Configuration on Appearance
You can use the `onSelfAppear` closure to dynamically configure the component:

```swift
InfoPairComponent { config in
    // Modify configuration when the component appears
    config.title = "Dynamic Title"
    config.description = "Dynamically updated description"
}
```

### Best Practices for Customization
- **Use Meaningful Titles and Descriptions**: Ensure that the title and description provide clear, concise information.
- **Maintain Consistency**: Try to keep the styling consistent across your application by using design tokens or a centralized configuration strategy.
- **Consider Variants**: As more variants are added to `InfoPairVariants`, you'll be able to create more diverse information pair styles.

## Advanced Usage

### Extending InfoPairComponentConfig
As your design system evolves, you might want to add more properties to the configuration:

```swift
internal class ExtendedInfoPairComponentConfig: InfoPairComponentConfig {
    @Published public var textColor: Color = .primary
    @Published public var fontSize: CGFloat = 16
}
```

This approach allows you to create more specialized configurations while maintaining the base functionality.

## Future Enhancements
The current implementation is deliberately simple to allow for future expansion. Potential future enhancements might include:
- Additional variants for different visual styles
- Support for custom typography
- Accessibility configuration options
- Localization support
