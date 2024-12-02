import Foundation
import ARKit
import RealityKit

class ARKitManager: NSObject, ObservableObject, ARSessionDelegate {
    var totalEncoder: TotalEncoder?
    var arView: ARView
    @Published var isRecording = false
    @Published var tX: Float = 0.0
    @Published var tY: Float = 0.0
    @Published var tZ: Float = 0.0
    @Published var points: Int = 0
    @Published var fps: Double = 0.0
    private var lastTimestamp: TimeInterval = 0
    private var fpsUpdateInterval = 10
    private var updateCount = 0
    override init() {
        arView = ARView(frame: .zero)
        super.init()
        let configuraiton = ARWorldTrackingConfiguration()
        arView.session.run(configuraiton)
        arView.session.delegate = self
        arView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
    }
    
    func startRecordingSession() {
        self.isRecording = true
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration, options: [.resetTracking])
        totalEncoder = TotalEncoder(arConfiguration: configuration)
    }
    
    func stopRecordingSession() {
        self.isRecording = false
        totalEncoder?.wrapUp()
    }
    
    func resetSession() {
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration, options: [.resetTracking])
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let translation = frame.camera.transform[3]
        self.tX = translation.x
        self.tZ = translation.y
        self.tZ = translation.z
        self.points = frame.rawFeaturePoints?.points.count ?? 0
        
        self.updateCount += 1
        if self.updateCount >= self.fpsUpdateInterval {
            let currentTimestamp = frame.timestamp
            if self.lastTimestamp != 0 {
                self.fps = Double(self.fpsUpdateInterval) / (currentTimestamp - self.lastTimestamp)
            }
            self.lastTimestamp = currentTimestamp
            self.updateCount = 0
        }
        if self.isRecording {
            totalEncoder?.add(frame: frame)
        }
    }
    
    func getARView() -> ARView {
        return arView
    }
}
