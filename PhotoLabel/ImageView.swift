//
//  ImageView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct ImageView: View {
    @Binding var showImageView: Bool
    let imageFile: String
    @State var lastValue: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    @State var location = CGPoint(x: 185, y: 310)
    @State var endLocation = CGPoint(x: 185, y: 310)
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            if let uiimage = UIImage(contentsOfFile: imageFile) {
                Image(uiImage: uiimage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(self.scale)
                    .position(location)
                    .gesture(DragGesture()
                        .onChanged { value in
                            self.location.x = value.location.x - (value.startLocation.x - self.endLocation.x)
                            self.location.y = value.location.y - (value.startLocation.y - self.endLocation.y)
                        }
                        .onEnded { value in
                            self.endLocation.x = self.location.x
                            self.endLocation.y = self.location.y
                        }
                    )
                    .gesture(MagnificationGesture()
                        .onChanged { value in
                            let delta = value / self.lastValue
                            self.scale = self.scale * delta
                            self.lastValue = value
                        }
                        .onEnded { value in
                            self.lastValue = 1.0
                        }
                    )
            }
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showImageView = false
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 30, height: 30)
                            .background(.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
