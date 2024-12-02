import Foundation
import ARKit
import CoreImage

class RGBImageEncoder {
    let path: URL
    let folderPath: URL
    let imageQueue = DispatchQueue(label: "com.sejunahn.imageQueue", qos: .utility)
    
    init(url: URL) {
        self.path = url
        self.folderPath = path.appendingPathComponent("RGB", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: self.folderPath.absoluteURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Can't create folder. \(error.localizedDescription)")
        }
    }
    func add(frame: ARFrame, currentFrame: Int) {
        let fileName = String(format: "%06d", currentFrame)
        let filePath = self.folderPath.absoluteURL.appendingPathComponent(fileName, isDirectory: false).appendingPathExtension("png")
        imageQueue.async {
            if let rgbImage = self.convert(frame: frame) {
                do {
                    try rgbImage.write(to: filePath)
                } catch let error {
                    print("Can't save RGB image \(currentFrame). \(error.localizedDescription)")
                }
            }
        }
    }
    
    func convert(frame: ARFrame) -> Data? {
        let pixelBuffer = frame.capturedImage
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        
        let scaleTransform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let scaledImage = ciImage.transformed(by: scaleTransform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        let uiImage = UIImage(cgImage: cgImage)
        let pngImage = uiImage.pngData()
        
        return pngImage
    }
}
