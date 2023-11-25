//
//  LottieViewUI.swift
//  Stickers
//
//  Created by  nikstar on 03.07.2021.
//

import SwiftUI
import Lottie

struct LottieViewUI: UIViewRepresentable {
    
    var animation: LottieAnimation
    var size: CGFloat
    
    func makeUIView(context: Context) -> UIView {
        let animation = LottieAnimationView(animation: animation)
        animation.loopMode = .loop
        animation.backgroundBehavior = .pauseAndRestore
        animation.contentMode = .scaleAspectFit
        animation.play()
        
        let view = UIView()
        animation.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animation)
        
        animation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animation.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        context.coordinator.heightConstraints = [
            animation.heightAnchor.constraint(equalToConstant: size),
            animation.widthAnchor.constraint(equalToConstant: size)
        ]
        context.coordinator.size = size
        NSLayoutConstraint.activate(context.coordinator.heightConstraints)
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        let animation = uiView.subviews[0] as! LottieAnimationView
        if size != context.coordinator.size {
            NSLayoutConstraint.deactivate(context.coordinator.heightConstraints)
            context.coordinator.heightConstraints = [
                animation.heightAnchor.constraint(equalToConstant: size),
                animation.widthAnchor.constraint(equalToConstant: size)
            ]
            context.coordinator.size = size
            NSLayoutConstraint.activate(context.coordinator.heightConstraints)
        }
    }
    
    final class Coordinator {
        var heightConstraints: [NSLayoutConstraint] = []
        var size: CGFloat = .zero
    }
}
