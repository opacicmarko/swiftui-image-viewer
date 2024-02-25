import SwiftUI

// MARK: - View

public struct ImageViewer: View {

    let image: Image
    let config: Config
    let onCloseTap: () -> Void

    public init(image: Image, onCloseTap: @escaping () -> Void, config: Config = .default) {
        self.image = image
        self.onCloseTap = onCloseTap
        self.config = config
    }

    @State private var baseScale: Double = 1.0
    @State private var scaleChange: Double = 1.0

    @State private var baseOffset: CGPoint = .zero
    @State private var nextOffset: CGPoint = .zero

    @State private var imageAspectRatio: Double = 1.0

    public var body: some View {
        VStack {
            GeometryReader { proxy in
                VStack {
                    Spacer()
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: proxy.size.width)
                        .scaleEffect(baseScale * scaleChange)
                        .offset(x: baseOffset.x + nextOffset.x, y: baseOffset.y + nextOffset.y)
                        .simultaneousGesture(
                            MagnificationGesture()
                                .onChanged { scale in
                                    scaleChange = scale.magnitude
                                    nextOffset = CGPoint(
                                        x: (baseOffset.x * (scale.magnitude - 1)),
                                        y: (baseOffset.y * (scale.magnitude - 1))
                                    )
                                }
                                .onEnded { _ in
                                    baseScale *= scaleChange
                                    baseOffset.x += nextOffset.x
                                    baseOffset.y += nextOffset.y
                                    nextOffset = .zero
                                    scaleChange = 1.0
                                    if self.baseScale < 1.0 {
                                        withAnimation {
                                            resetScale()
                                            resetOffset()
                                        }
                                    } else {
                                        withAnimation {
                                            snapEdgesToContainerMargins(containerSize: proxy.size, imageAspectRatio: imageAspectRatio)
                                        }
                                    }
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    if baseScale > 1.0 {
                                        nextOffset = CGPoint(
                                            x: (nextOffset.x + value.translation.width) / 2.0,
                                            y: (nextOffset.y + value.translation.height) / 2.0
                                        )
                                    } else {
                                        nextOffset = CGPoint(
                                            x: (nextOffset.x + value.translation.width) / 2.0,
                                            y: nextOffset.y
                                        )
                                    }
                                }
                                .onEnded { _ in
                                    baseOffset = CGPoint(
                                        x: baseOffset.x + nextOffset.x,
                                        y: baseOffset.y + nextOffset.y
                                    )
                                    nextOffset = .zero
                                    if baseScale <= 1.0 {
                                        withAnimation {
                                            resetOffset()
                                        }
                                    } else {
                                        withAnimation {
                                            snapEdgesToContainerMargins(containerSize: proxy.size, imageAspectRatio: imageAspectRatio)
                                        }
                                    }
                                }
                        )
                        .background(
                            GeometryReader { imageProxy in
                                Color.clear
                                    .onChange(of: imageProxy.size) { newValue in
                                        imageAspectRatio = newValue.aspectRatio()
                                    }
                            }
                        )
                    Spacer()
                }
            }
        }
        .padding(config.insets)
        .background(config.backgroundColor)
        .overlay {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        onCloseTap()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .renderingMode(.template)
                            .tint(.white)
                            .frame(width: 16, height: 16)
                    }
                    .padding(16)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Config

public extension ImageViewer {

    struct Config {
        let backgroundColor: Color
        let opacity: Double
        let insets: EdgeInsets

        public init(
            backgroundColor: Color,
            opacity: Double,
            insets: EdgeInsets
        ) {
            if opacity < 0.0 {
                self.opacity = 0
            } else if opacity >= 1.0 {
                self.opacity = 1.0
            } else {
                self.opacity = opacity
            }

            self.backgroundColor = backgroundColor.opacity(self.opacity)
            self.insets = insets
        }

        public static let `default` = Config(
            backgroundColor: Color.black,
            opacity: 1.0,
            insets: EdgeInsets(top: 48, leading: 0, bottom: 48, trailing: 0)
        )
    }
}

// MARK: - Scale and Offset actions

private extension ImageViewer {
    private func resetScale() {
        self.baseScale = 1.0
        self.scaleChange = 1.0
    }

    private func resetOffset() {
        self.baseOffset = .zero
        self.nextOffset = .zero
    }

    private func snapEdgesToContainerMargins(containerSize: CGSize, imageAspectRatio: Double) {
        let imageHeight = self.baseScale * (containerSize.width / imageAspectRatio)
        let clippableOffset = CGPoint(
            x: max(0, (self.baseScale - 1.0) * containerSize.width / 2.0),
            y: max(0, (imageHeight - containerSize.height) / 2.0)
        )
        if abs(self.baseOffset.x) > clippableOffset.x {
            self.baseOffset.x = self.baseOffset.x > 0 ? clippableOffset.x : -clippableOffset.x
        }
        if abs(self.baseOffset.y) > clippableOffset.y {
            self.baseOffset.y = self.baseOffset.y > 0 ? clippableOffset.y : -clippableOffset.y
        }
    }
}

private extension CGSize {
    func aspectRatio() -> Double {
        width / height
    }
}

// MARK: - View modifier

public struct ImagePreviewViewModifier: ViewModifier {

    public enum PresentationStyle {
        case sheet
        case fullScreenCover
    }

    @Binding var image: Image?
    let presentationStyle: PresentationStyle
    let config: ImageViewer.Config

    init(
        image: Binding<Image?>,
        presentationStyle: PresentationStyle,
        config: ImageViewer.Config
    ) {
        self._image = image
        self.presentationStyle = presentationStyle
        self.config = config
    }

    public func body(content: Content) -> some View {
        switch presentationStyle {
        case .sheet:
            content
                .sheet(isPresented: Binding(
                    get: { image != nil },
                    set: { image = $0 ? image : nil }
                )) {
                    if let image {
                        ImageViewer(
                            image: image,
                            onCloseTap: { self.image = nil },
                            config: config
                        )
                    }
                }
        case .fullScreenCover:
            content
                .fullScreenCover(isPresented: Binding(
                    get: { image != nil },
                    set: { image = $0 ? image : nil }
                )) {
                    if let image {
                        ImageViewer(
                            image: image,
                            onCloseTap: { self.image = nil },
                            config: config
                        )
                    }
                }
        }
    }
}

public extension View {
    func imagePreview(
        image: Binding<Image?>,
        presentationStyle: ImagePreviewViewModifier.PresentationStyle = .fullScreenCover,
        config: ImageViewer.Config = .default
    ) -> some View {
        self.modifier(
            ImagePreviewViewModifier(
                image: image,
                presentationStyle: presentationStyle,
                config: config
            )
        )
    }
}
