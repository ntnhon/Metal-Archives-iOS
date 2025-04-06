//
//  OffsetAwareScrollView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import SwiftUI

/*
 struct OffsetAwareVerticalScrollView<V: View>: UIViewRepresentable {
     let onScroll: (CGPoint) -> Void
     let content: V

     init(onScroll: @escaping (CGPoint) -> Void,
          @ViewBuilder content: () -> V) {
         self.onScroll = onScroll
         self.content = content()
     }

     func makeUIView(context: Context) -> UIScrollView {
         let scrollView = UIScrollView()
 //        scrollView.contentInsetAdjustmentBehavior = .automatic
 //        scrollView.backgroundColor = .clear
 //        scrollView.automaticallyAdjustsScrollIndicatorInsets = false
         let subview = UIHostingController(rootView: content).view!
         subview.backgroundColor = .clear
         subview.translatesAutoresizingMaskIntoConstraints = false
         scrollView.addSubview(subview)
         scrollView.delegate = context.coordinator
         let layoutGuide = scrollView.contentLayoutGuide
         NSLayoutConstraint.activate([
             subview.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
             subview.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
             subview.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
             subview.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
             subview.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
         ])
         return scrollView
     }

     func updateUIView(_ scrollView: UIScrollView, context: Context) {}

     func makeCoordinator() -> Coordinator { .init(self) }

     class Coordinator: NSObject, UIScrollViewDelegate {
         let parent: OffsetAwareVerticalScrollView

         init(_ parent: OffsetAwareVerticalScrollView) {
             self.parent = parent
         }

         func scrollViewDidScroll(_ scrollView: UIScrollView) {
             parent.onScroll(scrollView.contentOffset)
         }
     }
 }
 */

// https://betterprogramming.pub/swiftui-calculate-scroll-offset-in-scrollviews-c3b121f0b0dc
struct OffsetAwareScrollView<T: View>: View {
    let axes: Axis.Set
    let showsIndicator: Bool
    let onOffsetChanged: (CGPoint) -> Void
    let content: T

    init(axes: Axis.Set = .vertical,
         showsIndicator: Bool = true,
         onOffsetChanged: @escaping (CGPoint) -> Void = { _ in },
         @ViewBuilder content: () -> T)
    {
        self.axes = axes
        self.showsIndicator = showsIndicator
        self.onOffsetChanged = onOffsetChanged
        self.content = content()
    }

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicator) {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: OffsetPreferenceKey.self,
                    value: proxy.frame(
                        in: .named("ScrollViewOrigin")
                    ).origin
                )
            }
            .frame(width: 0, height: 0)
            content
        }
        .coordinateSpace(name: "ScrollViewOrigin")
        .onPreferenceChange(OffsetPreferenceKey.self,
                            perform: onOffsetChanged)
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static nonisolated(unsafe) var defaultValue: CGPoint = .zero

    static func reduce(value _: inout CGPoint, nextValue _: () -> CGPoint) {}
}
