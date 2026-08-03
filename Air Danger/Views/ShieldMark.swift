import SwiftUI

struct ShieldMark: View {
    var body: some View {
        ZStack {
            ShieldShape(rightHalfOnly: false)
                .fill(Color.accentColor)
            ShieldShape(rightHalfOnly: true)
                .fill(Palette.blueDeep)
        }
        .aspectRatio(24 / 28, contentMode: .fit)
    }
}

private struct ShieldShape: Shape {
    let rightHalfOnly: Bool

    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24
        let sy = rect.height / 28
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }

        var path = Path()
        path.move(to: p(12, 1.2))
        path.addLine(to: p(22, 5.1))
        path.addLine(to: p(22, 13.5))
        path.addCurve(to: p(12, 26.8), control1: p(22, 20.1), control2: p(17.7, 24.8))

        if !rightHalfOnly {
            path.addCurve(to: p(2, 13.5), control1: p(6.3, 24.8), control2: p(2, 20.1))
            path.addLine(to: p(2, 5.1))
        }

        path.closeSubpath()
        return path
    }
}

#Preview {
    ShieldMark()
        .frame(width: 76, height: 88)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
}
