// PropertyEditor.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/**
 The AnyKeyPath struct represents a type erased keypath which both has getter & setter methods.
 This wrapper aims to simplify the usage of most types by allowing you to if/else over them.

 This struct does the following:
 - Has an initializer to manually initialize all properties
 - Provides an initializer to initialize the code via a KeyPath
 */
public struct AnyKeyPath<TheObservedObject, TheValueType> {
    /// The display label for the property in the UI
    public let label: String

    /// A closure that retrieves the value from the observed object
    public let get: (TheObservedObject) -> TheValueType

    /// A closure that sets a new value on the observed object
    public let set: (inout TheObservedObject, TheValueType) -> Void

    /// The type information for the property
    public let type: Any.Type

    // swiftlint:disable force_cast
    /**
     Initializes an `AnyKeyPath` where the `get` and `set` properties makes use of KeyPath syntax.

     - Parameter label: The friendly label you want to represent to the user in the UI
     - Parameter keyPath: A `WritableKeyPath` reference from an `ObservableObject`
     */
    public init<ObservableWrappedValueType>(
        _ label: String,
        keyPath: WritableKeyPath<TheObservedObject, ObservableWrappedValueType>
    ) where ObservableWrappedValueType: Any {
        self.label = label
        get = { object in object[keyPath: keyPath] as! TheValueType }
        set = { object, value in
            var mutableObject = object
            mutableObject[keyPath: keyPath] = value as! ObservableWrappedValueType
        }
        type = ObservableWrappedValueType.self
    }
    // swiftlint:enable force_cast
}

/**
 A SwiftUI view that provides a slider and text input interface for editing numeric values.

 This view combines a slider for visual value adjustment with a text field for direct numeric input.
 */
private struct PaddingSliderInput: View {
    /// The binding to the value being edited
    @Binding public var value: CGFloat

    /// The label displayed next to the slider
    public let label: String

    /// The maximum allowed value for the slider
    public let max: CGFloat = 30

    public var body: some View {
        HStack {
            Text("\(label):")
            Slider(value: $value, in: 0 ... max, step: 1)
                .padding(.leading)
            TextField("", value: $value, formatter: NumberFormatter())
                .onChange(of: value) { oldValue, newValue in
                    if oldValue != newValue {
                        value = newValue
                    }
                }
                .frame(width: 30)
        }
    }
}

/**
 A SwiftUI view that provides an interface for editing EdgeInsets values.

 This view presents sliders for adjusting top, leading, bottom, and trailing edge inset values.
 */
public struct PaddingEditor: View {
    /// The binding to the EdgeInsets value being edited
    @Binding public var edgeInsets: EdgeInsets

    public var body: some View {
        VStack(spacing: 16) {
            PaddingSliderInput(value: $edgeInsets.top, label: "Top")
            PaddingSliderInput(value: $edgeInsets.leading, label: "Left")
            PaddingSliderInput(value: $edgeInsets.bottom, label: "Bottom")
            PaddingSliderInput(value: $edgeInsets.trailing, label: "Right")
        }
        .padding()
    }
}

/**
 A SwiftUI view that provides an interface for editing CGSize values.

 This view presents sliders for adjusting width and height values.
 */
internal struct CGSizeEdtior: View {
    /// The binding to the CGSize value being edited
    @Binding public var cgSize: CGSize

    public var body: some View {
        HStack {
            PaddingSliderInput(value: $cgSize.width, label: "W")
            Spacer()
            PaddingSliderInput(value: $cgSize.height, label: "H")
        }
    }
}

/**
 A SwiftUI view that provides a segmented picker interface for enum values.

 This view allows switching between different cases of a String-based enum using a segmented control.

 - Note: Supports special handling for DesignIcons enum values
 */
public struct EnumPropertyView<E: CaseIterable & RawRepresentable & Hashable>: View where E.RawValue == String {
    /// The binding to the enum value being edited
    @Binding public var value: E

    /// The array of enum cases to display as options
    public let cases: [E]

    public var body: some View {
        Picker("Select", selection: $value) {
            ForEach(cases, id: \.self) { variant in
                if let variant = variant as? DesignIcons {
                    variant.image
                } else {
                    Text(variant.rawValue)
                }
            }
        }.pickerStyle(.segmented)
    }

    /**
     Checks if a given type is a DesignIcon.

     - Parameter type: The type to check
     - Returns: True if the type is a DesignIcon, false otherwise
     */
    private func isDesignIcon(_ type: some Any) -> Bool {
        type is DesignIcons
    }
}

/**
 A SwiftUI view that provides a comprehensive property editing interface.

 This view creates a form-based editor for modifying properties of an ObservableObject,
 supporting various property types including strings, numbers, booleans, colors, and more.

 - Note: Properties must be passed individually, not as nested ObservableObjects
 */
public struct PropertyEditor<T: ObservableObject, Content: View>: View {
    /// The object whose properties are being edited
    @ObservedObject public var object: T

    /// A 2D array of property keypaths to edit
    public let properties: [[AnyKeyPath<T, Any>]]

    /// A closure that returns additional custom content to display
    @ViewBuilder public let viewer: () -> Content

    public var body: some View {
        VStack {
            viewer().padding()

            Form {
                ForEach(properties.indices, id: \.self) { index in
                    HStack {
                        ForEach(properties[index].indices, id: \.self) { item in
                            propertyRow(for: properties[index][item])
                        }
                    }
                }
            }
        }.preferredColorScheme(.dark)
    }

    // swiftlint:disable force_cast
    /**
     Creates an appropriate editing interface based on the property type.

     This method handles the following types:
     - String: Text field
     - Int: Stepper
     - Bool: Toggle
     - Double: Slider
     - EdgeInsets: Custom editor
     - CGFloat: Custom slider
     - Color: Color picker
     - CGSize: Custom size editor

     - Parameter property: The property keypath to create an editor for
     - Returns: A SwiftUI view appropriate for editing the property type
     */
    @ViewBuilder
    private func propertyRow(for property: AnyKeyPath<T, Any>) -> some View {
        let setFunc = { newValue in
            var mutableObject = object
            property.set(&mutableObject, newValue)
        }

        if property.type == String.self {
            let value = property.get(object) as! String
            HStack {
                Text("\(property.label):")
                TextField(property.label, text: Binding(
                    get: { value },
                    set: setFunc
                ))
            }
        } else if property.type == Int.self {
            let value = property.get(object) as! Int
            Stepper(
                "\(property.label): \(value)",
                value: Binding(
                    get: { value },
                    set: setFunc
                ),
                in: 0 ... 100
            )
        } else if property.type == Bool.self {
            let value = property.get(object) as! Bool
            Toggle("\(property.label): ", isOn: Binding(
                get: { value },
                set: setFunc
            ))
        } else if property.type == Double.self {
            let value = property.get(object) as! Double
            Slider(
                value: Binding(
                    get: { value },
                    set: setFunc
                ),
                in: 0 ... 100
            ) {
                Text("\(property.label): \(value, specifier: "%.1f")")
            }
        } else if type(of: property.get(object)) == EdgeInsets.self {
            let value = property.get(object) as! EdgeInsets
            PaddingEditor(edgeInsets: Binding(
                get: { value },
                set: setFunc
            ))
        } else if property.type == CGFloat.self {
            let value = property.get(object) as! CGFloat
            PaddingSliderInput(
                value: Binding(
                    get: { value },
                    set: setFunc
                ),
                label: property.label
            )
        } else if property.type == Color.self {
            let value = property.get(object) as! Color
            ColorPicker(
                "\(property.label):",
                selection:
                Binding(
                    get: {
                        value
                    },
                    set: setFunc
                )
            )
        } else if property.type == CGSize.self {
            let value = property.get(object) as! CGSize
            CGSizeEdtior(
                cgSize: Binding(
                    get: { value },
                    set: setFunc
                )
            )
        } else {
            Text("\(property.label)")
        }
    }
    // swiftlint:enable force_cast
}
