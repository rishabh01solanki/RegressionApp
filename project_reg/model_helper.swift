import CoreML

class CoreMLModelHelper {
    let model: MyModel  // Assuming the Core ML model's name is "MyModel"
    
    // Feature scaling statistics
    let featureMean: Float = 2000.0000000000002
    let featureStd: Float = 577.9279084228418
    
    // Label scaling statistics
    let labelMean: Float = 647.7371646254903
    let labelStd: Float = 180.0065320169323
    
    init() {
        do {
            self.model = try MyModel(configuration: MLModelConfiguration())
        } catch {
            fatalError("Failed to initialize Core ML model: \(error)")
        }
    }
    
    func runModelOnSize(_ size: Float) -> Float? {
        // Apply feature scaling to the input
        let scaledSize = (size - featureMean) / featureStd
        
        // Create the MLMultiArray for the scaled input
        guard let inputArray = try? MLMultiArray(shape: [1, 1], dataType: .float32) else {
            print("Error creating MLMultiArray")
            return nil
        }
        
        inputArray[0] = NSNumber(value: scaledSize)
        
        let input = MyModelInput(dense_input: inputArray)
        
        // Make the prediction
        do {
            let output = try model.prediction(input: input)
            // Assuming the output property is called 'Identity'
            let scaledOutput = output.Identity[0].floatValue
            
            // Apply inverse scaling to the output
            let finalOutput = (scaledOutput * labelStd) + labelMean
            return finalOutput
        } catch {
            print("Error running model: \(error)")
            return nil
        }
    }
}
