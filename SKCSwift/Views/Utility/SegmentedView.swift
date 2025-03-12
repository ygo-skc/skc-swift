//
//  SegmentedView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 9/5/23.
//

import SwiftUI

struct SegmentedView<MainContent: View, SheetContent: View>: View {
    @ViewBuilder var mainContent: () -> MainContent
    @ViewBuilder var sheetContent: () -> SheetContent
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            GeometryReader { reader in
                let frameHeight = reader.frame(in: .global).height
                let frameMidX = reader.frame(in: .global).midX
                
                mainContent()
                    .modifier(.parentView)
                
                
                BottomSheet(frameHeight: frameHeight, frameMidX: frameMidX) {
                    VStack(alignment: .center, spacing: 20) {
                        Capsule()
                            .fill(.gray.opacity(0.7))
                            .frame(width: 50, height: 5)
                            .padding(.top, 5)
                        sheetContent()
                    }
                    .background(GeometryReader { geometry in
                        Color.clear.preference(
                            key: BottomSheetMinHeightPreferenceKey.self,
                            value: geometry.size.height
                        )
                    })
                }
            }
        }
    }
}

private struct BottomSheet<SheetContent: View>: View {
    @State private var offset: CGFloat = 0
    @State private var bottomSheetHeight: CGFloat = 0
    
    var frameHeight: CGFloat
    var frameMidX: CGFloat
    
    @ViewBuilder var content: () -> SheetContent
    
    var body: some View {
        content()
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(BlurView(style: .systemMaterial))
            .cornerRadius(15)
            .shadow(radius: 3)
            .ignoresSafeArea(.all, edges: .bottom)
            .offset(y: frameHeight - bottomSheetHeight)
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
            .onPreferenceChange(BottomSheetMinHeightPreferenceKey.self) { [$bottomSheetHeight] newValue in
                $bottomSheetHeight.wrappedValue = newValue + 20
            }
        
        
    }
}

private struct BottomSheetMinHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
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

struct SegmentedView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedView(mainContent: {Text("Main Content")}) {
            Text("Bottom View")
        }
    }
}
