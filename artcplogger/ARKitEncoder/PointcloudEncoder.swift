import Foundation
import ARKit

class PointCloudEncoder {
    let path: URL
    let absPath: URL
    let fileHandle: FileHandle
    private var lastFrame: ARFrame?
    
    init(url: URL) {
        self.path = url.absoluteURL.appendingPathComponent("pointcloud", isDirectory: false).appendingPathExtension("csv")
        self.absPath = url.absoluteURL
        do {
            try "".write(to: self.path, atomically: true, encoding: .utf8)
            self.fileHandle = try FileHandle(forWritingTo: self.path)
            self.fileHandle.write("timestamp,frame,x,y,z\n".data(using: .utf8)!)
        } catch let error {
            print("Can't create file \(self.path.absoluteString). \(error.localizedDescription)")
            preconditionFailure("Can't open pointcloud file for writing.")
        }
    }
    
    func add(frame: ARFrame, currentFrame: Int, timestamp: Double) {
        self.lastFrame = frame
        let frameNumber = String(format: "%06d", currentFrame)
        if let points = frame.rawFeaturePoints?.points {
            for index in 0..<points.count {
                let x = points[index].x
                let y = points[index].y
                let z = points[index].z
                let line = "\(timestamp),\(frameNumber),\(x),\(y),\(z)\n"
                self.fileHandle.write(line.data(using: .utf8)!)
            }
        }
    }
    
    func intrinsics() {
        if let cameraMatrix = lastFrame?.camera.intrinsics {
            let rows = cameraMatrix.transpose.columns
            var intrinsics: [Float] = []
            for row in [rows.0, rows.1, rows.2] {
                intrinsics.append(row.x)
                intrinsics.append(row.y)
                intrinsics.append(row.z)
            }
            let intrinsicDict: [String: [Float]] = [
                "intrinsic": intrinsics
            ]
            do {
                let jsonData = try JSONEncoder().encode(intrinsicDict)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                
                let intrinsicPath = self.absPath.appendingPathComponent("intrinsic", isDirectory: false).appendingPathExtension("json")
                try jsonString.write(to: intrinsicPath, atomically: true, encoding: .utf8)
            } catch let error {
                print("Can't write intrinsic json file. \(error.localizedDescription)")
            }
        }
    }
    
    func done() {
        do {
            try self.fileHandle.close()
            self.intrinsics()
        } catch let error {
            print("Can't close pointcloud file \(self.path.absoluteString). \(error.localizedDescription)")
        }
    }
}
