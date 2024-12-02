import Foundation
import CoreMotion

class CoreMotionManager:NSObject, ObservableObject {
    var coremotionEncoder: CoreMotionEncoder?
    
    var coreMotion1: CMMotionManager?
    var coreMotion2: CMMotionManager?
    var coreMotion3: CMMotionManager?
    
    var timer = Timer()
    
    var accX: Double = 0.0
    var accY: Double = 0.0
    var accZ: Double = 0.0
    
    var linAccX: Double = 0.0
    var linAccY: Double = 0.0
    var linAccZ: Double = 0.0
    
    var gravX: Double = 0.0
    var gravY: Double = 0.0
    var gravZ: Double = 0.0
    
    var gyrX: Double = 0.0
    var gyrY: Double = 0.0
    var gyrZ: Double = 0.0
    
    var gyrUnX: Double = 0.0
    var gyrUnY: Double = 0.0
    var gyrUnZ: Double = 0.0
    
    var magX: Double = 0.0
    var magY: Double = 0.0
    var magZ: Double = 0.0
    
    var magUnX: Double = 0.0
    var magUnY: Double = 0.0
    var magUnZ: Double = 0.0
    
    var gameRvX: Double = 0.0
    var gameRvY: Double = 0.0
    var gameRvZ: Double = 0.0
    var gameRvW: Double = 0.0
    
    var rvX: Double = 0.0
    var rvY: Double = 0.0
    var rvZ: Double = 0.0
    var rvW: Double = 0.0
    
    var magRvX: Double = 0.0
    var magRvY: Double = 0.0
    var magRvZ: Double = 0.0
    var magRvW: Double = 0.0
    
    @Published var isStarted: Bool = false
    @Published var isRecording: Bool = false
    @Published var freq: Double = 0.0
    private var lastTimestamp: TimeInterval = 0
    private var fpsUpdateInterval = 10
    private var updateCount = 0
    private var coremotionQueue = OperationQueue()
    
    override init() {
        super.init()
        coreMotion1 = CMMotionManager()
        coreMotion2 = CMMotionManager()
        coreMotion3 = CMMotionManager()
        coremotionQueue.name = "com.sejunahn.coremotionManagerQueue"
        coremotionQueue.qualityOfService = .userInteractive
    }
    
    func startUpdate(_ freq: Double) {
        if coreMotion1!.isAccelerometerAvailable {
            coreMotion1?.startAccelerometerUpdates()
        }
        if coreMotion1!.isGyroAvailable {
            coreMotion1?.startGyroUpdates()
        }
        if coreMotion1!.isMagnetometerAvailable {
            coreMotion1?.startMagnetometerUpdates()
        }
        if coreMotion1!.isDeviceMotionAvailable {
            coreMotion1?.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        }
        if coreMotion2!.isDeviceMotionAvailable {
            coreMotion2?.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
        }
        if coreMotion3!.isDeviceMotionAvailable {
            coreMotion3?.startDeviceMotionUpdates(using: .xTrueNorthZVertical)
        }
        coremotionQueue.addOperation {
            
            self.timer = Timer.scheduledTimer(timeInterval: 1/freq, target: self, selector: #selector(self.getUpdate), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer, forMode: .common)
            RunLoop.current.run()
        }
        self.isStarted = true
    }
    
    func stopUpdate() {
        if coreMotion1!.isAccelerometerActive {
            coreMotion1?.stopAccelerometerUpdates()
        }
        if coreMotion1!.isGyroActive {
            coreMotion1?.stopGyroUpdates()
        }
        if coreMotion1!.isMagnetometerActive {
            coreMotion1?.stopMagnetometerUpdates()
        }
        if coreMotion1!.isDeviceMotionActive {
            coreMotion1?.stopDeviceMotionUpdates()
        }
        if coreMotion2!.isDeviceMotionActive {
            coreMotion2?.stopDeviceMotionUpdates()
        }
        if coreMotion3!.isDeviceMotionActive {
            coreMotion3?.stopDeviceMotionUpdates()
        }
        self.timer.invalidate()

        self.isStarted = false
    }
    
    func startRecording() {
        if self.isStarted {
            self.isRecording = true
            let directoryName = createDirectoryName()
            let directoryURL = getDirectoryURL(directoryName: directoryName)
            self.coremotionEncoder = CoreMotionEncoder(url: directoryURL)
        }
    }
    
    func stopRecording() {
        if self.isStarted {
            self.isRecording = false
            self.coremotionEncoder?.done()
        }
    }
    
    @objc func getUpdate() {
        DispatchQueue.main.async {
            if let data = self.coreMotion1?.accelerometerData {
                self.accX = data.acceleration.x
                self.accY = data.acceleration.y
                self.accZ = data.acceleration.z
            } else {
                self.accX = Double.nan
                self.accY = Double.nan
                self.accZ = Double.nan
            }
            if let data = self.coreMotion1?.gyroData {
                self.gyrUnX = data.rotationRate.x
                self.gyrUnY = data.rotationRate.y
                self.gyrUnZ = data.rotationRate.z
            } else {
                self.gyrUnX = Double.nan
                self.gyrUnY = Double.nan
                self.gyrUnZ = Double.nan
            }
            if let data = self.coreMotion1?.magnetometerData {
                self.magUnX = data.magneticField.x
                self.magUnY = data.magneticField.y
                self.magUnZ = data.magneticField.z
            } else {
                self.magUnX = Double.nan
                self.magUnY = Double.nan
                self.magUnZ = Double.nan
            }
            if let data = self.coreMotion1?.deviceMotion?.userAcceleration {
                self.linAccX = data.x
                self.linAccY = data.y
                self.linAccZ = data.z
            } else {
                self.linAccX = Double.nan
                self.linAccY = Double.nan
                self.linAccZ = Double.nan
            }
            if let data = self.coreMotion1?.deviceMotion?.gravity {
                self.gravX = data.x
                self.gravY = data.y
                self.gravZ = data.z
            } else {
                self.gravX = Double.nan
                self.gravY = Double.nan
                self.gravZ = Double.nan
            }
            if let data = self.coreMotion1?.deviceMotion?.rotationRate {
                self.gyrX = data.x
                self.gyrY = data.y
                self.gyrZ = data.z
            } else {
                self.gyrX = Double.nan
                self.gyrY = Double.nan
                self.gyrZ = Double.nan
            }
            if let data = self.coreMotion1?.deviceMotion?.attitude {
                self.gameRvW = data.quaternion.w
                self.gameRvX = data.quaternion.x
                self.gameRvY = data.quaternion.y
                self.gameRvZ = data.quaternion.z
            } else {
                self.gameRvW = Double.nan
                self.gameRvX = Double.nan
                self.gameRvY = Double.nan
                self.gameRvZ = Double.nan
            }
            
            if let data = self.coreMotion2?.deviceMotion?.magneticField {
                self.magX = data.field.x
                self.magY = data.field.y
                self.magZ = data.field.z
            } else {
                self.magX = Double.nan
                self.magY = Double.nan
                self.magZ = Double.nan
            }
            if let data = self.coreMotion2?.deviceMotion?.attitude {
                self.rvW = data.quaternion.w
                self.rvX = data.quaternion.x
                self.rvY = data.quaternion.y
                self.rvZ = data.quaternion.z
            } else {
                self.rvW = Double.nan
                self.rvX = Double.nan
                self.rvY = Double.nan
                self.rvZ = Double.nan
            }
            
            if let data = self.coreMotion3?.deviceMotion?.attitude {
                self.magRvW = data.quaternion.w
                self.magRvX = data.quaternion.x
                self.magRvY = data.quaternion.y
                self.magRvZ = data.quaternion.z
            } else {
                self.magRvW = Double.nan
                self.magRvX = Double.nan
                self.magRvY = Double.nan
                self.magRvZ = Double.nan
            }
            
            if self.isRecording {
                let timestamp = getTimestampSince1970()
                let line = "\(timestamp),\(self.accX),\(self.accY),\(self.accZ),\(self.linAccX),\(self.linAccY),\(self.linAccZ),\(self.gravX),\(self.gravY),\(self.gravZ),\(self.magX),\(self.magY),\(self.magZ),\(self.magUnX),\(self.magUnY),\(self.magUnZ),\(self.gyrX),\(self.gyrY),\(self.gyrZ),\(self.gyrUnX),\(self.gyrUnY),\(self.gyrUnZ),\(self.gameRvW),\(self.gameRvX),\(self.gameRvY),\(self.gameRvZ),\(self.rvW),\(self.rvX),\(self.rvY),\(self.rvZ),\(self.rvW),\(self.rvX),\(self.rvY),\(self.rvZ)\n"
                self.coremotionEncoder?.add(line: line)
            }
            
            self.updateCount += 1
            if self.updateCount >= self.fpsUpdateInterval {
                let currentTimestamp = Date().timeIntervalSince1970
                if self.lastTimestamp != 0 {
                    self.freq = Double(self.fpsUpdateInterval) / (currentTimestamp - self.lastTimestamp)
                }
                self.lastTimestamp = currentTimestamp
                self.updateCount = 0
            }
        }
    }
}

func getTimestampSince1970() -> String {
    let currentTime = Date().timeIntervalSince1970
    //let currentTimeString = String(Int(currentTime*1000))
    //return currentTimeString
    return String(currentTime)
}
