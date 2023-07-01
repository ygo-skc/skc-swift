//
//  BannedContent.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import SwiftUI

struct BannedContent: View {
    
    @State private var offset: CGFloat = 0
    
    private let height: CGFloat = 120
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            GeometryReader { reader in
                VStack {
                    Text("YOO")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                BottomSheet()
                    .offset(y: reader.frame(in: .global).height - height)
                    .offset(y: offset)
                    .gesture(DragGesture().onChanged { value in
                        if value.startLocation.y > reader.frame(in: .global).midX {
                            if value.translation.height < 0 && offset > (-reader.frame(in: .global).height + height) {
                                offset = value.translation.height
                            }
                        } else if value.startLocation.y < reader.frame(in: .global).midX {
                            if value.translation.height > 0 && offset < 0 {
                                offset = (-reader.frame(in: .global).height + height) + value.translation.height
                            }
                        }
                    }
                        .onEnded{ value in
                            withAnimation(.linear(duration: 0.18)) {
                                if value.startLocation.y > reader.frame(in: .global).midX {
                                    if -value.translation.height > reader.frame(in: .global).midX {
                                        offset = (-reader.frame(in: .global).height) + height
                                    } else {
                                        offset = 0
                                    }
                                } else if value.startLocation.y < reader.frame(in: .global).midX {
                                    if value.translation.height < reader.frame(in: .global).midX {
                                        offset = (-reader.frame(in: .global).height) + height
                                    } else {
                                        offset = 0
                                    }
                                }
                            }
                        }
                    )
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
                .padding(.top, 8)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity)
            BanListDatesView()
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(BlurView(style: .systemMaterial))
        .cornerRadius(15)
        .shadow(radius: 3)
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
