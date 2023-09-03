import SwiftUI

struct ContentView: View {
    let modelHelper = CoreMLModelHelper()
    
    @State private var houseSize: String = ""
    @State private var predictedPrices: [Float]? = nil
    @State private var labels: [String] = []
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func getPredictions() {
        guard let size = Float(houseSize) else {
            self.showError = true
            return
        }
        let sizes = [size - 200, size - 100, size, size + 100, size + 200]
        
        self.labels = sizes.map { String(Int($0)) }
        
        var predictions: [Float] = []
        for size in sizes {
            if let prediction = modelHelper.runModelOnSize(size) {
                predictions.append(prediction)
            }
        }

        self.predictedPrices = predictions
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.teal, .blue]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        hideKeyboard()
                    }

                VStack(spacing: 20) {
                    Text("House Price Predictor")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Image("house")
                        .resizable()
                        .frame(width: 300, height: 300, alignment: .center)
                    
                    // Your graph will go here
                    if let prices = predictedPrices {
                        GeometryReader { geometry in
                            LineGraph(data: prices.map { CGFloat($0) },
                                      labels: labels,
                                      pointsToHighlight: [0,1, 2, 3,4])
                                .frame(height:200)
                        }
        
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(16)
                            .padding(.bottom, 20)
                        
                        // Display the predicted price for the exact size
                                                Text("Predicted price for \(houseSize) sqft: $\(String(format: "%.2f", prices[2]))k")
                                                    .foregroundColor(.white)
                    }
                    
                    TextField("Enter size (sqft)", text: $houseSize)
                        .padding(10)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(8)
                        .keyboardType(.numberPad)
                        .foregroundColor(.white)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5, anchor: .center)
                    } else {
                        Button("Predict Price") {
                            hideKeyboard()
                            self.isLoading = true
                            DispatchQueue.global().async {
                                self.getPredictions()
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                }
                            }
                        }
                        .buttonStyle(PredictButtonStyle())
                    }
                    
                    if showError {
                        Text("Please enter a valid size.")
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
        }
    }
}

struct PredictButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
            .background(Color.green)
            .cornerRadius(8)
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

