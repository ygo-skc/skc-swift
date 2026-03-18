//
//  SegmentedView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 9/5/23.
//

import SwiftUI

struct SegmentedView<MainContent: View, SheetContent: View>: View {
    @Binding var mainSheetContentHeight: CGFloat
    let mainContent: MainContent
    let sheetContent: SheetContent
    
    init(mainSheetContentHeight: Binding<CGFloat>,
         @ViewBuilder mainContent: () -> MainContent,
         @ViewBuilder sheetContent: () -> SheetContent) {
        self._mainSheetContentHeight = mainSheetContentHeight
        self.mainContent = mainContent()
        self.sheetContent = sheetContent()
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            mainContent
            BottomSheet(mainSheetContentHeight: $mainSheetContentHeight) {
                sheetContent
            }
        }
    }
}

private struct BottomSheet<SheetContent: View>: View {
    @Binding var mainSheetContentHeight: CGFloat
    let content: SheetContent
    
    init(mainSheetContentHeight: Binding<CGFloat>, @ViewBuilder content: () -> SheetContent) {
        self._mainSheetContentHeight = mainSheetContentHeight
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            content
                .padding([.top, .bottom])
                .background(GeometryReader { geometry in
                    Color.clear.preference(
                        key: BottomSheetMinHeightPreferenceKey.self,
                        value: geometry.size.height
                    )
                })
                .onPreferenceChange(BottomSheetMinHeightPreferenceKey.self) { [$mainSheetContentHeight] newValue in
                    $mainSheetContentHeight.wrappedValue = newValue
                }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, minHeight: mainSheetContentHeight + 100, alignment: .topLeading)
        .background(BlurView(style: .systemMaterial))
        .cornerRadius(12)
        .shadow(radius: 4)
        .ignoresSafeArea(.all, edges: .bottom)
        .offset(y: 100)
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

