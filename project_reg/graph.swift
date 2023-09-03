// Assume this is in LineGraph.swift
import SwiftUI

struct LineGraph: View {
    var data: [CGFloat]
    var labels: [String]
    var pointsToHighlight: [Int]
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            let minDataValue = self.data.min() ?? 0
            let maxDataValue = self.data.max() ?? 0
            let stepX = frame.width / CGFloat(self.data.count - 1)
            let stepY = (frame.height) / (maxDataValue - minDataValue)
            
            // Draw the line
            Path { path in
                for i in 0..<self.data.count {
                    let x = CGFloat(i) * stepX
                    let y = frame.height - CGFloat(self.data[i] - minDataValue) * stepY
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
            
            // Highlight points
            ForEach(pointsToHighlight, id: \.self) { index in
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .offset(x: CGFloat(index) * stepX - 5, y: frame.height - CGFloat(self.data[index] - minDataValue) * stepY - 5)
            }
        }
    }
}

