import Foundation
import ARKit

struct VideoEncoderInput {
    let buffer: CVPixelBuffer
    let time: TimeInterval
}

class RGBVideoEncoder {
    private var videoWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput?
    private var videoAdapter: AVAssetWriterInputPixelBufferAdaptor?
    
    private let timeScale = CMTimeScale(60)
    
    public let width: CGFloat
    public let height: CGFloat
    
    private let systemBootedAt: TimeInterval
    private var previousFrame: Int = -1
    public var path: URL
    
    init(url: URL, width: CGFloat, height: CGFloat) {
        self.path = url
        self.systemBootedAt = ProcessInfo.processInfo.systemUptime
        
        self.width = width
        self.height = height
        initializeFile()
    }
    func add(frame: VideoEncoderInput, currentFrame: Int) {
        previousFrame = currentFrame
        while !videoWriterInput!.isReadyForMoreMediaData {
            print("Sleeping.")
            Thread.sleep(until: Date() + TimeInterval(0.01))
        }
        encode(frame: frame, frameNumber: currentFrame)
    }
    func done() {
        if videoWriter?.status == .failed {
            let error = videoWriter!.error
            print("Can't close RGB file. \(error!.localizedDescription)")
        } else {
            videoWriterInput?.markAsFinished()
            videoWriter?.finishWriting { [weak self] in
                self?.videoWriter = nil
                self?.videoWriterInput = nil
                self?.videoAdapter = nil
            }
        }
    }
    private func initializeFile() {
        self.path = self.path.absoluteURL.appendingPathComponent("RGB", isDirectory: false).appendingPathExtension("mp4")
        do {
            videoWriter = try AVAssetWriter(outputURL: self.path, fileType: .mp4)
            let settings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.hevc,
                AVVideoWidthKey: self.width,
                AVVideoHeightKey: self.height,
            ]
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            input.expectsMediaDataInRealTime = true
            input.mediaTimeScale = timeScale
            input.performsMultiPassEncodingIfSupported = false
            videoAdapter = createVideoAdapter(input)
            if videoWriter!.canAdd(input) {
                videoWriter!.add(input)
                videoWriterInput = input
                videoWriter!.startWriting()
                videoWriter!.startSession(atSourceTime: .zero)
            } else {
                print("Can't create writer.")
            }
        } catch let error {
            print("Creating AVAssetWriter failed. \(error), \(error.localizedDescription)")
        }
    }
    private func encode(frame: VideoEncoderInput, frameNumber: Int) {
        let image: CVImageBuffer = frame.buffer
        let time = CMTime(value: Int64(frameNumber), timescale: timeScale)
        let success = videoAdapter!.append(image, withPresentationTime: time)
        if !success {
            print("Failed to append frame \(frameNumber). \(videoWriter!.error!.localizedDescription)")
        }
    }
    private func createVideoAdapter(_ input: AVAssetWriterInput) -> AVAssetWriterInputPixelBufferAdaptor {
        return AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
    }
}
