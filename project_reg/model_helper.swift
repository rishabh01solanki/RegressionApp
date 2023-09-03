import Foundation
import TensorFlowLite

class ModelHelper {
    var interpreter: Interpreter?
    
    // Mean and standard deviation for house size from your Python script
    let featureMean: Float = 2000/* Insert your feature_mean here */
    let featureStd: Float = 577/* Insert your feature_std here */

    // Mean and standard deviation for house price from your Python script
    let labelMean: Float = 647/* Insert your label_mean here */
    let labelStd: Float = 180/* Insert your label_std here */

    init() {
        do {
            if let modelPath = Bundle.main.path(forResource: "linear_regression_model", ofType: "tflite") {
                interpreter = try Interpreter(modelPath: modelPath)
                try interpreter?.allocateTensors()
            } else {
                print("Failed to find the model file.")
            }
        } catch let error {
            print("Failed to create the interpreter with error: \(error.localizedDescription)")
        }
    }

    func runModel(inputData: Data) -> Float? {
        do {
            guard let interpreter = interpreter else {
                print("Interpreter is not initialized.")
                return nil
            }
            
            // Convert Data to Float and scale the input
            var input: Float = inputData.withUnsafeBytes { $0.load(as: Float.self) }
            var scaledInput = (input - featureMean) / featureStd
            
            // Create Data object from scaled input
            let scaledInputData = Data(buffer: UnsafeBufferPointer(start: &scaledInput, count: 1))
            
            // Run the model
            try interpreter.copy(scaledInputData, toInputAt: 0)
            try interpreter.invoke()
            
            let outputTensor = try interpreter.output(at: 0)
            var output: Float = 0.0
            _ = withUnsafeMutableBytes(of: &output) { outputTensor.data.copyBytes(to: $0) }
            
            // Scale back the output to original units
            let scaledOutput = (output * labelStd) + labelMean
            return scaledOutput
            
        } catch let error {
            print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
            return nil
        }
    }
    func runModelOnMultipleSizes(_ sizes: [Float]) -> [Float]? {
            var predictions: [Float] = []
            for size in sizes {
                withUnsafePointer(to: size) { pointer in
                    let inputData = Data(buffer: UnsafeBufferPointer(start: pointer, count: 1))
                    if let prediction = self.runModel(inputData: inputData) {
                        predictions.append(prediction)
                    }
                }
            }
            return predictions.count == sizes.count ? predictions : nil
        }
    
    
}

