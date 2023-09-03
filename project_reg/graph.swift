//this is in LineGraph.swift
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
            
            // Find the center x position based on the frame
            let centerX = frame.width / 2
            
            // Assuming user's input is in the center of the data array
            let centerIndex = data.count / 2
            
            // Highlight points and annotate
            ForEach(pointsToHighlight, id: \.self) { index in
                // Calculate x such that the user's inputted sq ft is centered
                let x = centerX + (CGFloat(index) - CGFloat(centerIndex)) * stepX
                let y = frame.height - CGFloat(self.data[index] - minDataValue) * stepY
                
                // Circle
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .offset(x: x - 5, y: y - 5)
                
                // Annotation
                Text("\(labels[index]) sqft, \(Int(self.data[index]))k")
                    .offset(x: x + 10, y: y - 20)
            }
        }
    }
}
