import SwiftUI

// MARK: - Sóng nước
struct Wave: Shape {
    var level: CGFloat          // 0...1, mực nước tính từ đáy
    var phase: Double           // dịch pha để sóng chạy
    var amplitude: CGFloat = 4

    var animatableData: CGFloat {
        get { level }
        set { level = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let baseY = rect.height * (1 - level)
        p.move(to: CGPoint(x: 0, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: baseY))
        for x in stride(from: 0.0, through: rect.width, by: 2) {
            let angle = (x / rect.width) * .pi * 2 + phase
            p.addLine(to: CGPoint(x: x, y: baseY + sin(angle) * amplitude))
        }
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.closeSubpath()
        return p
    }
}

// MARK: - Nền kính (Liquid Glass trên iOS 26+, fallback material)
private struct GlassBackground: ViewModifier {
    let shape: RoundedRectangle
    var tintColor: Color = .red

    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            content.glassEffect(.regular.tint(tintColor.opacity(0.75)).interactive(), in: shape)
        } else {
            content
                .background(shape.fill(tintColor.gradient))
                .background(.ultraThinMaterial, in: shape)
        }
    }
}

// MARK: - Giao diện nút danh mục
struct CategoryButtonLabel: View {
    let configuration: ButtonStyle.Configuration
    let title: String
    let imageName: String       // tên ảnh trong Assets (vd: "red_button", "yellow_button", v.v.)
    var tintColor: Color = .red
    var height: CGFloat = 64
    var imageSize: CGFloat = 68

    @State private var hovering = false
    @State private var spin = 0.0
    private let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)

    private var raised: Bool { hovering || configuration.isPressed }

    var body: some View {
        ZStack(alignment: .trailing) {
            // Thanh nút + nước bên trong
            ZStack(alignment: .leading) {
                TimelineView(.animation) { ctx in
                    let t = ctx.date.timeIntervalSinceReferenceDate
                    ZStack {
                        Wave(level: raised ? 0.85 : 0.45, phase: t * 2.2, amplitude: 5)
                            .fill(.white.opacity(0.22))
                        Wave(level: raised ? 0.75 : 0.35, phase: -t * 1.6 + 1.2, amplitude: 4)
                            .fill(.white.opacity(0.18))
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: raised)
                }
                .clipShape(shape)
                .allowsHitTesting(false)

                Text(title)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.leading, 18)
                    .padding(.trailing, imageSize * 0.85)
            }
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .leading)
            .modifier(GlassBackground(shape: shape, tintColor: tintColor))
            .shadow(color: tintColor.opacity(raised ? 0.55 : 0.3), radius: raised ? 16 : 10, y: 6)

            // Ảnh icon đè lên phía trên thanh góc phải
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
                .rotationEffect(.degrees(spin))
                .scaleEffect(raised ? 1.08 : 1)
                .shadow(color: .black.opacity(0.4), radius: 6, y: 5)
                .offset(x: 4)
        }
        .scaleEffect(configuration.isPressed ? 0.96 : 1)
        .offset(y: raised ? -2 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: raised)
        .onHover { hovering = $0 }                      // iPad / Mac / visionOS
        .onChange(of: configuration.isPressed) { _, pressed in
            if pressed {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) { spin += 360 }
            }
        }
    }
}

// Giữ lại PokedexLabel cho backward compatibility
typealias PokedexLabel = CategoryButtonLabel

// MARK: - ButtonStyle
struct PokedexButtonStyle: ButtonStyle {
    var title: String = "Pokedex"
    var ballImage: String = "red_button"
    var tintColor: Color = .red
    var height: CGFloat = 64
    var imageSize: CGFloat = 68

    func makeBody(configuration: Configuration) -> some View {
        CategoryButtonLabel(
            configuration: configuration,
            title: title,
            imageName: ballImage,
            tintColor: tintColor,
            height: height,
            imageSize: imageSize
        )
    }
}

typealias CategoryButtonStyle = PokedexButtonStyle

// MARK: - Reusable Category Button Component
struct CategoryButton: View {
    let title: String
    let imageName: String
    var tintColor: Color = .red
    var height: CGFloat = 64
    var imageSize: CGFloat = 68
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            EmptyView()
        }
        .buttonStyle(
            PokedexButtonStyle(
                title: title,
                ballImage: imageName,
                tintColor: tintColor,
                height: height,
                imageSize: imageSize
            )
        )
    }
}

// MARK: - Sử dụng Demo
struct PokedexButtonDemo: View {
    var body: some View {
        ZStack {
            Color(white: 0.08).ignoresSafeArea()
            VStack(spacing: 16) {
                CategoryButton(
                    title: "Pokedex",
                    imageName: "red_button",
                    tintColor: Color(red: 0.95, green: 0.32, blue: 0.32)
                ) {
                    print("Mở Pokedex")
                }
                
                CategoryButton(
                    title: "Moves",
                    imageName: "yellow_button",
                    tintColor: Color(red: 0.98, green: 0.62, blue: 0.15)
                ) {
                    print("Mở Moves")
                }
            }
            .padding()
        }
    }
}

#Preview { PokedexButtonDemo() }
