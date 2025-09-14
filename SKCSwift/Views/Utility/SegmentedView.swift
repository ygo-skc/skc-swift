//
//  SegmentedView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 9/5/23.
//

import SwiftUI

struct SegmentedView<MainContent: View, SheetContent: View>: View {
    @Binding var sheetHeight: CGFloat
    @ViewBuilder var mainContent: () -> MainContent
    @ViewBuilder var sheetContent: () -> SheetContent
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            GeometryReader { reader in
                let frame = reader.frame(in: .global)
                
                mainContent()
                
                BottomSheet(frame: frame) {
                    sheetContent()
                }
            }
        }
    }
}

private struct BottomSheet<SheetContent: View>: View {
    let frameHeight: CGFloat
    let frameMidX: CGFloat
    let content: () -> SheetContent
    
    @State private var offset: CGFloat = 0
    @State private var bottomSheetHeight: CGFloat = 0
    
    init(frame: CGRect, ViewBuilder content: @escaping () -> SheetContent) {
        self.frameHeight = frame.height
        self.frameMidX = frame.midX
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Capsule()
                .fill(.gray.opacity(0.7))
                .frame(width: 40, height: 5)
                .padding(.top, 5)
            content()
                .padding(.bottom)
        }
        .background(GeometryReader { geometry in
            Color.clear.preference(
                key: BottomSheetMinHeightPreferenceKey.self,
                value: geometry.size.height
            )
        })
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BlurView(style: .systemMaterial))
        .cornerRadius(15)
        .shadow(radius: 3)
        .ignoresSafeArea(.all, edges: .bottom)
        .offset(y: frameHeight - bottomSheetHeight + offset)
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
                withAnimation(.bouncy(duration: 0.1, extraBounce: 0.1)) {
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
            $bottomSheetHeight.wrappedValue = newValue
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

//struct SegmentedView_Previews: PreviewProvider {
//    static var previews: some View {
//        SegmentedView(mainContent: {Text("Main Content")}) {
//            Text("Bottom View")
//        }
//    }
//}
