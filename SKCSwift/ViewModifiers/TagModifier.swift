//
//  TagModifier.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/12/25.
//

import SwiftUI

struct TagConstants {
    static let HORIZONTAL_PADDING: CGFloat = 8
    static let VERTICAL_PADDING: CGFloat = 3
    static let FONT: Font = .caption2
    static let NEUTRAL_WASH: Color = Color(UIColor.systemGray4)
    
    fileprivate static let ICON_SPACING: CGFloat = 3
    fileprivate static let ACCENT_WASH: Color = .accentColor.opacity(0.12)
    fileprivate static let STATUS_WASH_OPACITY: CGFloat = 0.15
    fileprivate static let STATUS_STROKE_OPACITY: CGFloat = 0.5
    fileprivate static let STROKE_WIDTH: CGFloat = 0.5
}

enum TagVariant {
    case accent             // accent text on accent wash - semantic/notable content
    case neutral            // secondary text on gray wash - metadata
    case solid(Color)       // white text on solid fill - selected states only
    case status(Color)      // primary text on color wash + stroke - ban status
}

/// Tightens the gap between a `Label`'s icon and title - the stock label style reserves a wide icon column that
/// looks unbalanced inside a capsule tag. No-op for tags built from plain `Text`.
private struct TagLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: TagConstants.ICON_SPACING) {
            configuration.icon
            configuration.title
        }
    }
}

struct TagModifier: ViewModifier {
    private let font: Font
    private let foreground: Color
    private let background: Color
    private let stroke: Color?
    
    init(variant: TagVariant = .accent, font: Font = TagConstants.FONT) {
        self.font = font
        switch variant {
        case .accent:
            (foreground, background, stroke) = (.accentColor, TagConstants.ACCENT_WASH, nil)
        case .neutral:
            (foreground, background, stroke) = (.primary, TagConstants.NEUTRAL_WASH, nil)
        case .solid(let color):
            (foreground, background, stroke) = (.white, color, nil)
        case .status(let color):
            (foreground, background, stroke) = (.primary, color.opacity(
                TagConstants.STATUS_WASH_OPACITY), color.opacity(TagConstants.STATUS_STROKE_OPACITY))
        }
    }
    
    func body(content: Content) -> some View {
        content
            .labelStyle(TagLabelStyle())
            .font(font)
            .fontWeight(.medium)
            .lineLimit(1)
            .dynamicTypeSize(...DynamicTypeSize.large)
            .padding(.horizontal, TagConstants.HORIZONTAL_PADDING)
            .padding(.vertical, TagConstants.VERTICAL_PADDING)
            .foregroundStyle(foreground)
            .background(background, in: .capsule)
            .overlay {
                if let stroke {
                    Capsule()
                        .strokeBorder(stroke, lineWidth: TagConstants.STROKE_WIDTH)
                }
            }
    }
}

extension View {
    func tagModifier(_ variant: TagVariant = .accent, font: Font = TagConstants.FONT) -> some View {
        modifier(TagModifier(variant: variant, font: font))
    }
}
