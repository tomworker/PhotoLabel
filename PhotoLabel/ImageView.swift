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
    @State var location = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    @State var endLocation = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    @State var leftEdge: CGFloat = 0
    @State var rightEdge: CGFloat = UIScreen.main.bounds.width
    @State var topEdge: CGFloat = 0
    @State var bottomEdge: CGFloat = UIScreen.main.bounds.height
    @State var aspectRatio: CGFloat = 1.0
    
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
                            aspectRatio = uiimage.size.height / uiimage.size.width
                            leftEdge = value.location.x - (value.startLocation.x - self.endLocation.x) - UIScreen.main.bounds.width * self.scale / 2
                            rightEdge = value.location.x - (value.startLocation.x - self.endLocation.x) + UIScreen.main.bounds.width * self.scale / 2
                            topEdge = value.location.y - (value.startLocation.y - self.endLocation.y) - UIScreen.main.bounds.width * aspectRatio * self.scale / 2
                            bottomEdge = value.location.y - (value.startLocation.y - self.endLocation.y) + UIScreen.main.bounds.width * aspectRatio * self.scale / 2
                            if leftEdge <= 0 && rightEdge >= UIScreen.main.bounds.width {
                                self.location.x = value.location.x - (value.startLocation.x - self.endLocation.x)
                            }
                            if topEdge <= (UIScreen.main.bounds.height - UIScreen.main.bounds.width * aspectRatio) / 2 && bottomEdge >= (UIScreen.main.bounds.height + UIScreen.main.bounds.width * aspectRatio) / 2 {
                                self.location.y = value.location.y - (value.startLocation.y - self.endLocation.y)
                            }
                        }
                        .onEnded { value in
                            self.endLocation.x = self.location.x
                            self.endLocation.y = self.location.y
                        }
                    )
                    .gesture(MagnificationGesture()
                        .onChanged { value in
                            let delta = value / self.lastValue
                            leftEdge = self.location.x - UIScreen.main.bounds.width * self.scale * delta / 2
                            rightEdge = self.location.x + UIScreen.main.bounds.width * self.scale * delta / 2
                            topEdge = self.location.y - UIScreen.main.bounds.width * aspectRatio * self.scale * delta / 2
                            bottomEdge = self.location.y + UIScreen.main.bounds.width * aspectRatio * self.scale * delta / 2
                            if self.scale * delta >= 1.0 {
                                if leftEdge <= 0 && rightEdge >= UIScreen.main.bounds.width {
                                    //none
                                } else if leftEdge > 0 {
                                    self.location.x = rightEdge / 2
                                } else if rightEdge < UIScreen.main.bounds.width {
                                    self.location.x = (leftEdge + UIScreen.main.bounds.width) / 2
                                }
                                if topEdge <= (UIScreen.main.bounds.height - UIScreen.main.bounds.width * aspectRatio) / 2 && bottomEdge >= (UIScreen.main.bounds.height + UIScreen.main.bounds.width * aspectRatio) / 2 {
                                    //none
                                } else if topEdge > (UIScreen.main.bounds.height - UIScreen.main.bounds.width * aspectRatio) / 2 {
                                    self.location.y = (bottomEdge + (UIScreen.main.bounds.height - UIScreen.main.bounds.width * aspectRatio) / 2) / 2
                                } else if bottomEdge < (UIScreen.main.bounds.height + UIScreen.main.bounds.width * aspectRatio) / 2 {
                                    self.location.y = (topEdge + (UIScreen.main.bounds.height + UIScreen.main.bounds.width * aspectRatio) / 2) / 2
                                }
                                self.scale = self.scale * delta
                                self.lastValue = value
                            } else {
                                self.scale = 1.0
                                self.lastValue = value
                                location = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                                endLocation = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                            }
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
