import Foundation
import CoreMotion

class CoreMotionEncoder {
    let path: URL
    let fileHandle: FileHandle
    
    private var dispatchGroup = DispatchGroup()
    private var coremotionQueue: DispatchQueue
    
    init(url: URL) {
        self.path = url.absoluteURL.appendingPathComponent("imu", isDirectory: false).appendingPathExtension("csv")
        do {
            try "".write(to: self.path, atomically: true, encoding: .utf8)
            self.fileHandle = try FileHandle(forWritingTo: self.path)
            self.fileHandle.write("timestamp,ax,ay,az,bx,by,bz,cx,cy,cz,dx,dy,dz,ex,ey,ez,fx,fy,fz,gx,gy,gz,hw,hx,hy,hz,iw,ix,iy,iz,jw,jx,jy,jz\n".data(using: .utf8)!)
            // a: acceleration, b:userAcceleration, c: gravity
            // d: magnet, e: magnet_uncalibrated, f: gyroscope, g: gyroscope_uncalibrated
            // h: game_rotationVector, i: rotationVector, j: magnet_rotationVector
        } catch let error {
            print("Can't create file \(self.path.absoluteString). \(error.localizedDescription)")
            preconditionFailure("Can't open IMU file for writing.")
        }
        
        self.coremotionQueue = DispatchQueue(label: "com.sejunahn.coremotionEncoderQueue")
    }
    
    func add(line: String) {
        dispatchGroup.enter()
        coremotionQueue.async {
            self.fileHandle.write(line.data(using: .utf8)!)
            self.dispatchGroup.leave()
        }
    }
    
    func done() {
        dispatchGroup.wait()
        do {
            try self.fileHandle.close()
        } catch let error {
            print("Can't close IMU file \(self.path.absoluteString). \(error.localizedDescription)")
        }
    }
}
