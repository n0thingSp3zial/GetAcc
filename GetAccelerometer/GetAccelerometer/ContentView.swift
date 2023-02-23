//
//  ContentView.swift
//  GetAccelerometer
//
//  Created by Олег Чикин on 19.11.2022.
//

//https://github.com/AppPear/ChartView.git

import SwiftUI
import SwiftUICharts
import CoreMotion

struct ContentView: View {
    
    
    @State private var isLoading = false
    @State private var RecordSessionIsOn = false
    @State private var RecordSessionIsStopped = true
    @State private var FileName = ""
    
    // Setup Motion Manager
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
    // Record Values
    @State var x_acceleration: [Double] = []
    @State var y_acceleration: [Double] = []
    @State var z_acceleration: [Double] = []
    
    @State var x_rotation: [Double] = []
    @State var y_rotation: [Double] = []
    @State var z_rotation: [Double] = []
    
        
    struct userAcc : Codable {
        let index : Int
        let x_acc : Double
        let y_acc : Double
        let z_acc : Double
        let x_rot : Double
        let y_rot : Double
        let z_rot : Double
    }
    
    @State var forJSONAcceleration: [userAcc] = []
    @State var JSONData: Data = Data.init()
    @State var JSONString: String = ""
    @State var shareURL: Any = 69
    @State var shareSTRorFILE = false   // false - STR | true - FILE
        
    
    var body: some View {
        ZStack {
            Color(UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1))
                .ignoresSafeArea()
            if !RecordSessionIsOn {
                Button(action: {
                    withAnimation() {
                        self.RecordSessionIsOn.toggle()
                        self.RecordSessionIsStopped.toggle()
                    }
                }) {
                    Text("Start")
                        .frame(width: 300, height: 120, alignment: .center)
                        .font(.system(size:50))
                }
                .buttonStyle(.bordered)
                .tint(.green)
                .controlSize(.large)
            }
            if RecordSessionIsOn {
                VStack {
                    MultiLineChartView(
                        data:
                            [
                                (x_acceleration.suffix(100), GradientColors.green),      // убрать suffix?
                                (y_acceleration.suffix(100), GradientColors.prplNeon),
                                (z_acceleration.suffix(100), GradientColors.orngPink)
                            ],
                        title: "Acceleration",
                        form: ChartForm.extraLarge,
                        rateValue: 228,
                        dropShadow: true
                        
                    )
                    //.padding(5)
                    MultiLineChartView(
                        data:
                            [
                                (x_rotation.suffix(100), GradientColors.green),      // убрать suffix?
                                (y_rotation.suffix(100), GradientColors.prplNeon),
                                (z_rotation.suffix(100), GradientColors.orngPink)
                            ],
                        title: "Rotation",
                        form: ChartForm.extraLarge,
                        rateValue: 69,
                        dropShadow: true
                        
                    )
                    .padding(5)
                    ZStack {
                        if !self.RecordSessionIsStopped {
                            Button(action: {
                                
                                // stop data collection
                                self.motionManager.stopDeviceMotionUpdates()
                                
                                // make JSON encoder
                                let encoder = JSONEncoder()
                                encoder.outputFormatting = .Element(arrayLiteral: .sortedKeys, .prettyPrinted)
                                
                                // create JSON string for .txt file
                                do {
                                    
                                    self.JSONData = try encoder.encode(self.forJSONAcceleration)
                                    self.JSONString = String(data: self.JSONData, encoding: .utf8)!
                                    
                                } catch { print(error) }
                                
                                // get file name
                                withAnimation() {
                                    alertTextField(title: "FileName",
                                                   message: "Please Enter Your Name To Save Gesture") { text in
                                        self.FileName = text
                                        print(self.FileName)
                                        //==============================
                                        
                                        let manager = FileManager.default
                                        
                                        // get url for the app
                                        guard let url = manager.urls(
                                            for: .documentDirectory,
                                            in: .userDomainMask
                                        ).first else {
                                            return
                                        }
                                        
                                        // create user folder
                                        var userName = self.FileName
                                        let needle: Character = "_"
                                        if let idx = self.FileName.firstIndex(of: needle) {
                                            let pos = self.FileName.distance(from: self.FileName.startIndex,
                                                                             to: idx)
                                            userName = String(self.FileName.prefix(pos))
                                        }
                                        else {
                                            print("Not found")
                                        }
                                        
                                        do {
                                            try manager.createDirectory(
                                                at: url.appendingPathComponent(userName),
                                                withIntermediateDirectories: true)
                                        }
                                        catch {
                                            print(error)
                                        }
                                        
                                        // get file url
                                        let fileURL = url.appendingPathComponent(userName).appendingPathComponent(self.FileName).appendingPathExtension("json")
                                        self.shareURL = fileURL
                                        
                                        // create file with content
                                        manager.createFile(
                                            atPath: fileURL.path,
                                            contents: self.JSONString.data(using: .utf8)
                                        )
                                        
                                        //==============================
                                        
                                        withAnimation() {
                                            self.shareSTRorFILE = true              // sharing file
                                            self.RecordSessionIsStopped.toggle()    // remove red button
                                        }
                                    } secondaryAction: {
                                        print("Cancelled")  // debug
                                        
                                        withAnimation() {
                                            self.shareSTRorFILE = false                 // sharing str
                                            self.RecordSessionIsStopped.toggle()        // remove red button
                                        }
                                    }
                                }
                            }) {
                                Text("Stop")
                                    .frame(width: 250, height: 100, alignment: .center)
                                    .font(.system(size:40))
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .controlSize(.large)
                        }
                        else {
                            VStack {
                                // send string (if 'cancel' when asked for filename)
                                if self.shareSTRorFILE {
                                    ShareLink(item: UIDocument(fileURL: self.shareURL as! URL).fileURL) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                            .frame(width: 250, height: 30, alignment: .center)
                                            .font(.system(size:25))
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)
                                }
                                // send .txt file if filename was entered
                                else {
                                    ShareLink(item: self.JSONString) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                            .frame(width: 250, height: 30, alignment: .center)
                                            .font(.system(size:25))
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)
                                }
                                Button(action: {
                                    
                                    // DON'T remove temporary file
                                    
                                    // remove old data
                                    self.forJSONAcceleration.removeAll()
                                    self.x_acceleration.removeAll()
                                    self.y_acceleration.removeAll()
                                    self.z_acceleration.removeAll()
                                    
                                    withAnimation() {
                                        self.RecordSessionIsOn.toggle()
                                    }
                                }) {
                                    Text("Save")
                                        .frame(width: 250, height: 30, alignment: .center)
                                        .font(.system(size:25))
                                }
                                .buttonStyle(.bordered)
                                .tint(.green)
                                Button(action: {
                                    
                                    // remove temporary file
                                    let manager = FileManager.default
                                    
                                    if self.shareSTRorFILE {    // if true - sharing file => need to clean
                                        do {
                                            try manager.removeItem(at: self.shareURL as! URL)
                                            print("deleted successfully!")
                                        }
                                        catch {
                                            print(error)
                                        }
                                    }
                                    
                                    // remove old data
                                    self.forJSONAcceleration.removeAll()
                                    self.x_acceleration.removeAll()
                                    self.y_acceleration.removeAll()
                                    self.z_acceleration.removeAll()
                                    
                                    withAnimation() {
                                        self.RecordSessionIsOn.toggle()
                                    }
                                }) {
                                    Text("Back")
                                        .frame(width: 250, height: 30, alignment: .center)
                                        .font(.system(size:25))
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            }
                            .padding(10)
                        }
                    }
                }
                .onAppear {
                    
                    // Modify Motion Manager
                    self.motionManager.deviceMotionUpdateInterval = 1.0 / 100.0          // 100 Hz
                    self.motionManager.startDeviceMotionUpdates(to: self.queue) {
                        (data: CMDeviceMotion?, error: Error?) in
                        
                        forJSONAcceleration.append(userAcc(index: forJSONAcceleration.count,
                                                           x_acc: Double(data!.userAcceleration.x),
                                                           y_acc: Double(data!.userAcceleration.y),
                                                           z_acc: Double(data!.userAcceleration.z),
                                                           x_rot: Double(data!.rotationRate.x),
                                                           y_rot: Double(data!.rotationRate.y),
                                                           z_rot: Double(data!.rotationRate.z)
                                                          ))

                        x_acceleration.append(forJSONAcceleration.last!.x_acc)
                        y_acceleration.append(forJSONAcceleration.last!.y_acc)
                        z_acceleration.append(forJSONAcceleration.last!.z_acc)
                        
                        x_rotation.append(forJSONAcceleration.last!.x_rot)
                        y_rotation.append(forJSONAcceleration.last!.y_rot)
                        z_rotation.append(forJSONAcceleration.last!.z_rot)
                                                                        
                    }
                }
            }
        }
    }
    
}

func getCurrentTime() -> String {
    let date = Date()
    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)
    let month = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    let sec = calendar.component(.second, from: date)
    let theDate = "\(day)_\(month)_\(year)_\(hour)_\(minutes)_\(sec)"
    return theDate
}

var prevName = ""

extension View {
    func alertTextField(title: String,
                        message: String,
                        primaryAction: @escaping (String)->(),
                        secondaryAction: @escaping ()->()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = "Name"
        }
        
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
            secondaryAction()
        }))
        
        alert.addAction(.init(title: "Infinity", style: .default, handler: { _ in
            if let text = alert.textFields?[0].text {
                if text != "" {
                    prevName = text
                    primaryAction(text + "_infinity_" + getCurrentTime())
                }
                else {
                    primaryAction(prevName + "_infinity_" + getCurrentTime())
                }
            }
            else {
                primaryAction("infinity_" + getCurrentTime())
            }
        }))
        
        alert.addAction(.init(title: "Star", style: .default, handler: { _ in
            if let text = alert.textFields?[0].text {
                if text != "" {
                    primaryAction(text + "_star_" + getCurrentTime())
                }
                else {
                    primaryAction(prevName + "_star_" + getCurrentTime())
                }
            }
            else {
                primaryAction("star_" + getCurrentTime())
            }
        }))
        
        alert.addAction(.init(title: "Cat", style: .default, handler: { _ in
            if let text = alert.textFields?[0].text {
                if text != "" {
                    primaryAction(text + "_cat_" + getCurrentTime())
                }
                else {
                    primaryAction(prevName + "_cat_" + getCurrentTime())
                }
            }
            else {
                primaryAction("cat_" + getCurrentTime())
            }
        }))
        
        // Presenting Alert
        rootController().present(alert, animated: true, completion: nil)
    }
    // Root View Controller
    func rootController()->UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
