# SwiftUI Image Viewer

An Image Viewer built with SwiftUI.

## Installation

### Swift Package Manager 
The [Swift Package Manager](https://www.swift.org/documentation/package-manager/) is a tool for managing dependencies in Swift projects.
It is included in Swift 3.0 and above, and is the recommended way to install SwiftUI Image Viewer.

Add the following to your `dependencies` in your `Package.swift` file:
```swift
dependencies: [
    .package(url: "https://github.com/opacicmarko/swiftui-image-viewer.git", from: "0.1.0")
]
```

## Usage
Simply import the `ImageViewer` module and use the `ImageViewer` view where necessary.
For example, you could use the `ImageViewer` in a sheet:
```swift
import SwiftUI
import ImageViewer

struct SimpleExample: View {
    let image = Image("Waterfall")
    @State private var isImagePreviewPresented: Bool = false

    var body: some View {
        VStack {
            Button("Tap me to show image preview!") {
                isImagePreviewPresented = true
            }
        }
        .fullScreenCover(isPresented: $isImagePreviewPresented) {
            ImageViewer(
                image: image,
                onCloseTap: {
                    isImagePreviewPresented = false
                }
            )
        }
    }
}
```

There is also an `ImagePreviewViewModifier` to make it easier to view your image in a `sheet` or `fullScreenCover`:
```swift
struct ImagePreviewExample: View {
    @State private var previewImage: Image?

    var body: some View {
        VStack {
            Button("Tap me to show image preview!") {
                previewImage = Image("Waterfall")
            }
        }
        .imagePreview(image: $previewImage, presentationStyle: .sheet)
    }
}

```

## License
SwiftUI Image Viewer is licensed under the MIT License. See [LICENSE](https://github.com/opacicmarko/swiftui-image-viewer/blob/main/LICENSE) for details.