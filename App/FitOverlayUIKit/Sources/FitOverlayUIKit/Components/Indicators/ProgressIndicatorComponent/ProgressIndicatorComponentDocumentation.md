# ProgressIndicatorComponent

## Overview
<!-- Give a reason behind this component & what it is doing -->
The `ProgressIndicatorComponent` is used to represent any form of loading or progression. This component centralizes the logic for this and easily allows for extensibility / wrapping to create custom implementations of the component logic!

## Design
LINK: [FIGMA](https://www.figma.com/design/x5MkR0UFRMUkp0eiAXVbmy/FitOverlayUIKit?node-id=635-22)

## Usage
<!-- Explain how to use the component here -->
<!-- Ensure to provide at-least one example per initializer to make the user understand the scope of the component -->
<!-- Add one image per initializer (This is UI after all) -->

#### Where to use this component
1. When indicating some kind of progress while a user is completing it.
    a. Onboarding Screens
    b. Explaining new features
    c. Creating / Form filling screens
    d. Payments
2. To indicate that something is loading / fetching
    a. Querying the API to get some response back
    b. Starting up the application
    c. Progression bar to keep the app interactive on a long running task

#### How to use this component
This component can be used extremely simply by using the 1 initializer that is currently active.
```swift
@ObservableObject public var config = ProgressIndicatorComponentConfig()
...
ProgressIndicatorComponent(config: config, onSelfAppear: ((config) -> Void)?)
```

#### Experimenting
The UI library provides many preview files which all contain a suffix `Previews` to allow you to experiment with them. The Specific preview file for testing the `ProgressIndicatorComponent` can be found at `Sources/FitOverlayUIKit/Components/Indicators/ProgressIndicatorComponent/ProgressIndicatorComponentPreviews.swift`

## Props/Parameters
| Property | Type | Description |
|----------|------|-------------|
| `config` | ProgressIndicatorComponentConfig | Configuration for the component. |

## Guidelines
<!-- Explain when and when not to use the component based on past experience -->
There are guidelines for using this component, these guidelines attempt to prevent the misuse of components which could ruin the aesthetic of an application.

**When Not To Use:**
- Attempt to never have more than one progress bar on the screen in the context of a loading screen. The application should fetch data in parallel to prevent multiple unsynced loading states

**When To Use:**
- A long running task, this is to notify the user that something is still happening and the action didn't fail
- The loading of a resource heavy asset, as these take long the user might think the app is broken /bugged

## Customization
<!-- Explain how users can customize the component via the "Config" object in ProgressIndicatorComponentConfig Struct -->
Customization should be done only to extend the component or in the very rare cases that the design requires brekaing the consistency of this component.


## Future Enhancements
- Add more variants to this component to make it useable throughout the app
    - An actual loading bar
    - Loading Spinner (Similar to SwiftUI's `ProgressView` - but flat)
- Expose this functionality to allow futures to control the state (for loading / APIS)
