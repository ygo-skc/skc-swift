//
//  TodayView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import SwiftUI

struct TodayView<T: View, U: View>: View {
    let cardOfTheDay: () -> T
    let productsReleasedToday: () -> U
    
    init(@ViewBuilder cardOfTheDay: @escaping () -> T, @ViewBuilder productsReleasedToday: @escaping () -> U) {
        self.cardOfTheDay = cardOfTheDay
        self.productsReleasedToday = productsReleasedToday
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionView(header: "Today",
                        content: {
                cardOfTheDay()
            })
            .padding(.bottom)
            
            Text("Released on this day")
                .font(.headline)
            productsReleasedToday()
        }
    }
}

struct CardOfTheDayView: View, Equatable {
    static func == (lhs: CardOfTheDayView, rhs: CardOfTheDayView) -> Bool {
        lhs.cotd == rhs.cotd
        && lhs.dataTaskStatus == rhs.dataTaskStatus
    }
    
    @Binding var path: NavigationPath
    let cotd: CardOfTheDay
    let dataTaskStatus: DataTaskStatus
    let networkError: NetworkError?
    let retryCB: () async -> Void
    
    private static let IMAGE_SIZE: CGFloat = 90
    
    var body: some View {
        if let networkError {
            NetworkErrorView(error: networkError, action: { Task { await retryCB() } })
        } else {
            Button {
                path.append(CardLinkDestinationValue(cardID: cotd.card.cardID, cardName: cotd.card.cardName))
            } label: {
                HStack(alignment: .top, spacing: 15) {
                    CardImageView(length: CardOfTheDayView.IMAGE_SIZE, cardID: cotd.card.cardID, imgSize: .tiny, cardColor: cotd.card.cardColor)
                        .equatable()
                    VStack(alignment: .leading, spacing: 5) {
                        InlineDateView(date: cotd.date)
                            .equatable()
                        Text(cotd.card.cardName)
                            .lineLimit(2)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(cotd.card.cardType)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                    }
                }
                .if(dataTaskStatus != .done) {
                    $0.redacted(reason: .placeholder)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // needed so button can be clicked everywhere
                .contentShape(Rectangle())
            }
            .disabled(dataTaskStatus != .done && networkError == nil)
            .buttonStyle(.plain)
        }
    }
}

struct ProductsReleasedTodayView: View, Equatable {
    static func == (lhs: ProductsReleasedTodayView, rhs: ProductsReleasedTodayView) -> Bool {
        lhs.productsReleasedToday == rhs.productsReleasedToday
        && lhs.dataTaskStatus == rhs.dataTaskStatus
    }
    
    let productsReleasedToday: [Product]
    let dataTaskStatus: DataTaskStatus
    let networkError: NetworkError?
    let retryCB: () async -> Void
    
    private static let IMAGE_SIZE: CGFloat = 90
    
    var body: some View {
        if let networkError {
            NetworkErrorView(error: networkError, action: { Task { await retryCB() } })
        } else {
            if dataTaskStatus == .done, productsReleasedToday.isEmpty {
                ContentUnavailableView("On this day, Konami rested", systemImage: "tray.fill")
            } else {
                LazyVStack {
                    ForEach(dataTaskStatus == .done ? productsReleasedToday : Product.placeholders, id: \.id) { product in
                        GroupBox {
                            ProductListItemView(product: product)
                                .equatable()
                        }
                        .groupBoxStyle(.listItem)
                        .transition(.opacity)
                    }
                }
                .if(dataTaskStatus != .done) {
                    $0.redacted(reason: .placeholder)
                }
                .animation(.smooth(duration: 0.25), value: dataTaskStatus)
                .disabled(dataTaskStatus != .done && networkError == nil)
            }
        }
    }
}

#Preview("Default") {
    @Previewable @State var path = NavigationPath()
    
    NavigationStack {
        CardOfTheDayView(path: $path,
                         cotd: CardOfTheDay(
                            date: "2025-02-24",
                            card: YGOCard(cardID: "68762510", cardName: "Lucky Pied Piper", cardColor: "Effect", cardAttribute: "Wind" , cardEffect: ""),
                            version: 1),
                         dataTaskStatus: .done, networkError: nil, retryCB: {})
        .padding(.horizontal)
    }
}

#Preview("Loading") {
    @Previewable @State var path = NavigationPath()
    
    NavigationStack {
        CardOfTheDayView(path: $path,
                         cotd: CardOfTheDay(
                            date: "2025-02-24",
                            card: YGOCard(cardID: "68762510", cardName: "Lucky Pied Piper", cardColor: "Effect", cardAttribute: "Wind", cardEffect: ""),
                            version: 1),
                         dataTaskStatus: .pending, networkError: nil, retryCB: {})
        .padding(.horizontal)
    }
}

#Preview("Network Error") {
    @Previewable @State var path = NavigationPath()

    NavigationStack {
        CardOfTheDayView(path: $path,
                         cotd: CardOfTheDay(
                            date: "2025-02-24",
                            card: YGOCard(cardID: "68762510", cardName: "Lucky Pied Piper", cardColor: "Effect", cardAttribute: "Wind", cardEffect: ""),
                            version: 1),
                         dataTaskStatus: .error, networkError: .timeout, retryCB: {})
        .padding(.horizontal)
    }
}

#Preview("Products - Default") {
    ProductsReleasedTodayView(productsReleasedToday: [Product(productId: "PHNI", productLocale: "EN", productName: "Phantom Nightmare",
                                                              productType: "Pack", productSubType: "Core Set",
                                                              productReleaseDate: "2024-02-09", productTotal: 100)],
                              dataTaskStatus: .done, networkError: nil, retryCB: {})
    .padding(.horizontal)
}

#Preview("Products - Loading") {
    ProductsReleasedTodayView(productsReleasedToday: [],
                              dataTaskStatus: .pending, networkError: nil, retryCB: {})
    .padding(.horizontal)
}

#Preview("Products - Network Error") {
    ProductsReleasedTodayView(productsReleasedToday: [],
                              dataTaskStatus: .error, networkError: .timeout, retryCB: {})
    .padding(.horizontal)
}
