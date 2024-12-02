import Foundation
import ARKit

class PointCloudEncoder {
    let path: URL
    let fileHandle: FileHandle
    
    init(url: URL) {
        self.path = url.absoluteURL.appendingPathComponent("pointcloud", isDirectory: false).appendingPathExtension("csv")
        do {
            try "".write(to: self.path, atomically: true, encoding: .utf8)
            self.fileHandle = try FileHandle(forWritingTo: self.path)
            self.fileHandle.write("timestamp,frame,x,y,z\n".data(using: .utf8)!)
        } catch let error {
            print("Can't create file \(self.path.absoluteString). \(error.localizedDescription)")
            preconditionFailure("Can't open pointcloud file for writing.")
        }
    }
    func add(frame: ARFrame, currentFrame: Int) {
        let frameNumber = String(format: "%06d", currentFrame)
        if let points = frame.rawFeaturePoints?.points {
            for index in 0..<points.count {
                let x = points[index].x
                let y = points[index].y
                let z = points[index].z
                let line = "\(frame.timestamp),\(frameNumber),\(x),\(y),\(z)\n"
                self.fileHandle.write(line.data(using: .utf8)!)
            }
        }
    }
    func done() {
        do {
            try self.fileHandle.close()
        } catch let error {
            print("Can't close pointcloud file \(self.path.absoluteString). \(error.localizedDescription)")
        }
    }
}
