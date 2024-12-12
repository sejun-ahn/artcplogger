import Foundation
import ARKit

class TransformEncoder {
    let path: URL
    let fileHandle: FileHandle
    
    init(url: URL) {
        self.path = url.absoluteURL.appendingPathComponent("transform", isDirectory: false).appendingPathExtension("csv")
        do {
            try "".write(to: self.path, atomically: true, encoding: .utf8)
            self.fileHandle = try FileHandle(forWritingTo: self.path)
            self.fileHandle.write("timestamp,frame,x,y,z,qx,qy,qz,qw\n".data(using: .utf8)!)
        } catch let error {
            print("Can't create file \(self.path.absoluteString). \(error.localizedDescription)")
            preconditionFailure("Can't open transform file for writing.")
        }
    }
    func add(frame: ARFrame, currentFrame: Int, timestamp: Double) {
        let transform = frame.camera.transform
        let t = transform[3]
        let q = simd_quatf(transform).vector
        let frameNumber = String(format: "%06d", currentFrame)
        let line = "\(timestamp),\(frameNumber),\(t.x),\(t.y),\(t.z),\(q.x),\(q.y),\(q.z),\(q.w)\n"
        self.fileHandle.write(line.data(using: .utf8)!)
    }
    func done() {
        do {
            try self.fileHandle.close()
        } catch let error {
            print("Can't close transform file \(self.path.absoluteString). \(error.localizedDescription)")
        }
    }
}
