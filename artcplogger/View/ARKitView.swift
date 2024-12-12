//
// Sejun Ahn
// github: github.com/sejun-ahn
//

import SwiftUI
import ARKit
import RealityKit

#Preview {
    ARKitView()
}

struct ARKitView: View {
    @ObservedObject var arkitManager = ARKitManager()
    @ObservedObject var socketManager = SocketManager.shared
    @ObservedObject var coremotionManager = CoreMotionManager()
    var body: some View {
        ZStack {
            
            ARKitViewContainer(arkitManager: arkitManager)
                .ignoresSafeArea(edges: .all)
                .background(.white)
            VStack(spacing: 5) {
                CoreMotionView(coremotionManager: coremotionManager)
                ARKitBoxView(arkitManager: arkitManager)
                SocketBoxView(socketManager: socketManager)
            }
            .onAppear(perform: {
                SocketManager.shared.addAction(for: "a", action: { content in
                    if !arkitManager.isRecording {
                        arkitManager.startRecordingSession(directoryName: convertTimeString2(date: content))
                    }
                    if coremotionManager.isStarted && !coremotionManager.isRecording {
                        coremotionManager.startRecording(directoryName: convertTimeString2(date: content))
                    }
                })
                SocketManager.shared.addAction(for: "b", action: { content in 
                    if arkitManager.isRecording {
                        arkitManager.stopRecordingSession()
                    }
                    if coremotionManager.isStarted && coremotionManager.isRecording {
                        coremotionManager.stopRecording()
                    }
                })
            })
        }
    }
        
}

struct ARKitViewContainer: UIViewRepresentable {
    @ObservedObject var arkitManager: ARKitManager
    func makeUIView(context: Context) -> ARView {
        return arkitManager.getARView()
    }
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}


struct ARKitBoxView: View {
    @ObservedObject var arkitManager: ARKitManager
    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 5) {
                VStack(spacing: 5) {
                    Text("X")
                        .frame(width: 80, height: 30, alignment: .center)
                        .cornerRadius(6)
                        .foregroundColor(.black)
                    Text(String(format: "%.3f",arkitManager.tX))
                        .frame(width: 80, height: 30, alignment: .center)
                        .background(Color.white)
                        .cornerRadius(6)
                        .foregroundColor(.red)
                }
                VStack(spacing: 5) {
                    Text("Y")
                        .frame(width: 80, height: 30, alignment: .center)
                        .cornerRadius(6)
                        .foregroundColor(.black)

                    Text(String(format: "%.3f",arkitManager.tY))
                        .frame(width: 80, height: 30, alignment: .center)
                        .background(Color.white)
                        .cornerRadius(6)
                        .foregroundColor(.green)

                }
                VStack(spacing: 5) {
                    Text("Z")
                        .frame(width: 80, height: 30, alignment: .center)
                        .cornerRadius(6)
                        .foregroundColor(.black)

                    Text(String(format: "%.3f",arkitManager.tZ))
                        .frame(width: 80, height: 30, alignment: .center)
                        .background(Color.white)
                        .cornerRadius(6)
                        .foregroundColor(.blue)

                }
                VStack(spacing: 5) {
                    Text("Features")
                        .frame(width: 80, height: 30, alignment: .center)
                        .cornerRadius(6)
                        .foregroundColor(.black)

                    Text("\(arkitManager.points)")
                        .frame(width: 80, height: 30, alignment: .center)
                        .background(Color.white)
                        .cornerRadius(6)
                        .foregroundColor(.black)

                }
            }//HStack for displaying values
            HStack(spacing: 5) {
                Text(String(format: "%.2f FPS",arkitManager.fps))
                    .frame(width: 165, height: 30, alignment: .center)
                    .background(Color.white)
                    .cornerRadius(6)
                    .foregroundColor(.black)
                Button(action: {
                    if !arkitManager.isRecording {
                        arkitManager.startRecordingSession()
                    } else {
                        arkitManager.stopRecordingSession()
                    }
                }, label: {
                    Image(systemName: arkitManager.isRecording ? "stop.circle.fill" : "play.circle.fill")
                    Text(arkitManager.isRecording ? "STOP" : "START")
                })
                .mediumStyle()
                .toggleButtonStyle(flag: arkitManager.isRecording)
            }
        }
        .frame(width: 345, height: 110, alignment: .center)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(6)
        .shadow(radius: 1)
    }
}
