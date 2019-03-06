import Cocoa
import CreateML

var str = "Hello, playground"

let featureColumns = ["t1p1x", "t1p1y", "t1p2x", "t1p2y", "t1Radius", "t1TimeDelta", "t2p1x", "t2p1y", "t2p2x", "t2p2y", "t2Radius", "t2TimeDelta"]

let url = URL.init(fileURLWithPath: "/users/Matt/projects/TouchNodeServer/data.json")

let text = try String.init(contentsOf: url)

do {
    let dataTable = try MLDataTable.init(contentsOf: url)
    let (trainingData, testingData) =
        dataTable.randomSplit(by: 0.8, seed: 0)
    
    let predictor = try MLClassifier.init(trainingData: trainingData, targetColumn: "isMarkup", featureColumns: featureColumns)

    
    let testDataUrl = URL.init(fileURLWithPath: "/Users/Matt/projects/TouchNodeServer/testData.json")
    print("loaded test data")
    if let testData = try? MLDataTable.init(contentsOf: testDataUrl) {
    
        let metrics = predictor.evaluation(on: testingData)
        print(metrics)
    } else {
        print("error loading test data")
    }
    do {
        var outputURL = URL(fileURLWithPath: "/Users/Matt/TouchClassifier.mlmodel")
    try predictor.write(to: outputURL, metadata: nil)
    } catch {
        print("error writing model \(error)")
    }
    print("done")

    
} catch {
    print("error creating classifier \(error)")
}
