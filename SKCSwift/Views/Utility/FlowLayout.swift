//
//  FlowLayout.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/27/25.
//

import SwiftUI

// stolen from https://gist.github.com/aheze/1cbd2d36764c978b28aa20a00cb4b5b6 (an amazing implementation I wish I understood and came up with)
struct FlowLayout: Layout {
    var spacing = CGFloat(5)
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.replacingUnspecifiedDimensions().width
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, containerWidth: containerWidth).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = layout(sizes: sizes, containerWidth: bounds.width).offsets
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: CGPoint(x: offset.x + bounds.minX, y: offset.y + bounds.minY), proposal: .unspecified)
        }
    }
    
    func layout(sizes: [CGSize], containerWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
        var result: [CGPoint] = []
        var currentPosition: CGPoint = .zero
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        for size in sizes {
            if currentPosition.x + size.width > containerWidth {
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            
            result.append(currentPosition)
            currentPosition.x += size.width
            maxX = max(maxX, currentPosition.x)
            currentPosition.x += spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        return (result, CGSize(width: maxX, height: currentPosition.y + lineHeight))
    }
}

struct TagModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .font(.caption)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
            ))
            .foregroundColor(.white)
            .cornerRadius(6)
            .lineLimit(1)
            .dynamicTypeSize(...DynamicTypeSize.medium)
    }
}

#Preview {
    FlowLayout {
        Group {
            Text("Javi Gomez")
            Text("Rebecca Craven")
            Text("Dawn Gomez")
            Text("Rose Gomez")
            Text("Ady G")
            Text("Lupe Gomez")
        }
        .modifier(TagModifier())
    }
    .padding(.horizontal)
}
