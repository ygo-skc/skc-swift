//
//  SegmentedView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 9/5/23.
//

import SwiftUI

struct SegmentedView<MainContent: View, SheetContent: View>: View {
    @Binding var mainSheetContentHeight: CGFloat
    @ViewBuilder var mainContent: () -> MainContent
    @ViewBuilder var mainSheetContent: () -> SheetContent
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            GeometryReader { reader in
                let frame = reader.frame(in: .global)
                
                mainContent()
                
                BottomSheet(frame: frame, mainSheetContentHeight: $mainSheetContentHeight) {
                    mainSheetContent()
                }
            }
        }
    }
}

private struct BottomSheet<SheetContent: View>: View {
    let frameHeight: CGFloat
    let frameMidX: CGFloat
    @Binding var mainSheetContentHeight: CGFloat
    let content: () -> SheetContent
    
    @State private var offset: CGFloat = 0
    @State private var bottomSheetHeight: CGFloat = 0
    
    init(frame: CGRect, mainSheetContentHeight: Binding<CGFloat>, ViewBuilder content: @escaping () -> SheetContent) {
        self.frameHeight = frame.height
        self.frameMidX = frame.midX
        self._mainSheetContentHeight = mainSheetContentHeight
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack {
                Capsule()
                    .fill(.gray.opacity(0.7))
                    .frame(width: 40, height: 5)
                    .padding([.top, .bottom], 5)
                content()
                    .padding(.bottom)
            }
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: BottomSheetMainContentHeightPreferenceKey.self,
                    value: geometry.size.height
                )
            })
            .onPreferenceChange(BottomSheetMainContentHeightPreferenceKey.self) { [$mainSheetContentHeight] newValue in
                $mainSheetContentHeight.wrappedValue = newValue
            }
        }
        .background(GeometryReader { geometry in
            Color.clear.preference(
                key: BottomSheetMinHeightPreferenceKey.self,
                value: geometry.size.height
            )
        })
        .onPreferenceChange(BottomSheetMinHeightPreferenceKey.self) { [$bottomSheetHeight] newValue in
            $bottomSheetHeight.wrappedValue = newValue
        }
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
    }
}

private struct BottomSheetMinHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct BottomSheetMainContentHeightPreferenceKey: PreferenceKey {
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

