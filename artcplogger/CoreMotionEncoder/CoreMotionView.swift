//
//  CoreMotionView.swift
//  tcplogger
//
//  Created by mpilmini on 11/2/24.
//

import SwiftUI

struct CoreMotionView: View {
    @ObservedObject var coremotionManager: CoreMotionManager
    var body: some View {
        VStack(spacing: 5) {
            Text("CoreMotion")
                .frame(width: 335, height: 30, alignment: .center)
                .cornerRadius(6)
                .foregroundColor(.black)
            HStack(spacing: 5) {
                Text(coremotionManager.isStarted ? String(format: "%.2f FPS", coremotionManager.freq) : "0.00 FPS" )
                    .frame(width: 165, height: 30)
                    .background(Color.white)
                    .cornerRadius(6)
                    .foregroundStyle(.black)
                Button(action: {
                    if coremotionManager.isStarted {
                        coremotionManager.stopUpdate()
                    } else {
                        coremotionManager.startUpdate(200)
                    }
                }, label: {
                    Text(coremotionManager.isStarted ? "STOP" : "START")
                })
                    .frame(width: 80, height: 30)
                    .background(coremotionManager.isStarted ? Color.red : Color.green)
                    .cornerRadius(6)
                    .foregroundColor(.white)
                    .disabled(coremotionManager.isRecording)
                Button(action: {
                    if coremotionManager.isStarted && !coremotionManager.isRecording {
                        coremotionManager.startRecording()
                    } else if coremotionManager.isStarted && coremotionManager.isRecording {
                        coremotionManager.stopRecording()
                    }
                }, label: {
                    Text(coremotionManager.isRecording ? "DONE" : "REC")
                })
                    .frame(width: 80, height: 30)
                    .background(coremotionManager.isRecording ? Color.red : Color.green)
                    .cornerRadius(6)
                    .foregroundColor(.white)
                    .disabled(!coremotionManager.isStarted)
            }
        }
        .frame(width: 345, height: 75, alignment: .center)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(6)
        .shadow(radius: 1)
    }
}

