//
//  BannedContent.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import SwiftUI

struct BannedContent: View {
    
    @State private var offset: CGFloat = 0
    @State private var bottomSheetHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            GeometryReader { reader in
                let frameHeight = reader.frame(in: .global).height
                let frameMidX = reader.frame(in: .global).midX
                
                VStack(alignment: .leading) {
                    Text("YOO")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal)
                BottomSheet()
                    .offset(y: reader.frame(in: .global).height - bottomSheetHeight)
                    .offset(y: offset)
                    .gesture(DragGesture().onChanged { value in
                        if value.startLocation.y > frameMidX {
                            if value.translation.height < 0 && offset > (-frameHeight + bottomSheetHeight) {
                                offset = value.translation.height
                            }
                        } else if value.startLocation.y < frameMidX {
                            if value.translation.height > 0 && offset < 0 {
                                offset = (-frameHeight + bottomSheetHeight) + value.translation.height
                            }
                        }
                    }
                        .onEnded{ value in
                            withAnimation(.linear(duration: 0.18)) {
                                if value.startLocation.y > frameMidX {
                                    if -value.translation.height > frameMidX {
                                        offset = (-frameHeight) + bottomSheetHeight
                                    } else {
                                        offset = 0
                                    }
                                } else if value.startLocation.y < frameMidX {
                                    if value.translation.height < frameMidX {
                                        offset = (-frameHeight) + bottomSheetHeight
                                    } else {
                                        offset = 0
                                    }
                                }
                            }
                        }
                    )
                    .onPreferenceChange(BanListDatesBottomViewMinHeightPreferenceKey.self) {
                        bottomSheetHeight = $0
                    }
            }
        }
    }
}


private struct BottomSheet: View {
    var body: some View {
        VStack(alignment: .leading) {
            Capsule()
                .fill(.gray.opacity(0.7))
                .frame(width: 50, height: 5)
                .padding(.top)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity)
            BanListDatesView()
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(BlurView(style: .systemMaterial))
        .cornerRadius(15)
        .shadow(radius: 3)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

private struct BlurView : UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}

struct BannedContent_Previews: PreviewProvider {
    static var previews: some View {
        BannedContent()
    }
}
