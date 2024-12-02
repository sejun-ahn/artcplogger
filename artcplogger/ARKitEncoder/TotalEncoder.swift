import Foundation
import ARKit

class TotalEncoder {
    private let rgbvideoEncoder: RGBVideoEncoder
    private let transformEncoder: TransformEncoder
    private let pointcloudEncoder: PointCloudEncoder
    
    private var dispatchGroup = DispatchGroup()
    private let totalQueue: DispatchQueue
    
    private var currentFrame: Int = -1
    private var savedFrames: Int = 0
    private let frameInterval: Int
    
    init(arConfiguration: ARWorldTrackingConfiguration, fpsDivider: Int = 1) {
        self.frameInterval = fpsDivider
        self.totalQueue = DispatchQueue(label: "com.sejunahn.totalQueue")
        
        let width = arConfiguration.videoFormat.imageResolution.width
        let height = arConfiguration.videoFormat.imageResolution.height
        
        let directoryName = createDirectoryName()
        let directoryURL = getDirectoryURL(directoryName: directoryName)
        
        self.rgbvideoEncoder = RGBVideoEncoder(url: directoryURL ,width: width, height: height)
        self.transformEncoder = TransformEncoder(url: directoryURL)
        self.pointcloudEncoder = PointCloudEncoder(url: directoryURL)
    }
    
    func add(frame: ARFrame) {
        let totalFrames: Int = currentFrame
        let frameNumber: Int = savedFrames
        currentFrame += 1
        if (currentFrame % frameInterval != 0) {
            return
        }
        
        dispatchGroup.enter()
        totalQueue.async {
            self.rgbvideoEncoder.add(frame: VideoEncoderInput(buffer: frame.capturedImage, time: frame.timestamp), currentFrame: totalFrames)
            self.transformEncoder.add(frame: frame, currentFrame: frameNumber)
            self.pointcloudEncoder.add(frame: frame, currentFrame: frameNumber)
            self.dispatchGroup.leave()
        }
        savedFrames += 1
    }
    func wrapUp() {
        dispatchGroup.wait()
        self.rgbvideoEncoder.done()
        self.transformEncoder.done()
        self.pointcloudEncoder.done()
        currentFrame = 0
    }
}

func createDirectoryName() -> String {
    let format = DateFormatter()
    format.dateFormat = "yyMMdd_HHmmss"
    return format.string(from: Date())
}

func getDirectoryURL(directoryName: String) -> URL {
    let directoryName = directoryName
    let fileManager = FileManager.default
    let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let directoryURL = documentURL.absoluteURL.appending(path: directoryName)
    
    do {
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    } catch let error {
        print(error)
    }
    
    return directoryURL
}
