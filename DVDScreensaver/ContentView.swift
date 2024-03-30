//
//  ContentView.swift
//  DVDScreensaver
//
//  Created by Aryaman Sharda on 3/22/24.
//

import SwiftUI

@MainActor
final class DisplayLink {
    private var displaylink: CADisplayLink?
    private var update: (() -> Void)?

    func start(update: @escaping () -> Void) {
        self.update = update

        // CADisplayLink represents a timer bound to the refresh rate of the device's display
        displaylink = CADisplayLink(
            target: self,
            selector: #selector(frame)
        )
        displaylink?.add(to: .current, forMode: .default)
    }

    func stop() {
        displaylink?.invalidate()
        update = nil
    }

    @objc func frame() {
        update?()
    }
}

@MainActor
struct ContentView: View {
    @State private var position: CGPoint = .zero
    @State private var velocity: CGVector = CGVector(dx: 5, dy: 5)
    @State private var imageColor: Color = .green
    @State private var displayLink = DisplayLink()

    private let canvasSize: CGSize = UIScreen.main.bounds.size
    private let imageSize: CGSize = CGSize(width: 128, height: 76)
    private let image = Image("dvd_logo")

    var body: some View {
        Canvas { [position] context, size in
            // Set the background color to .black
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))

            // Draw image at current position
            var image = context.resolve(image)
            image.shading = .color(imageColor)
            context.draw(
                image,
                in: CGRect(x: position.x, y: position.y, width: imageSize.width, height: imageSize.height)
            )
        }
        .onAppear {
            // Set initial position to the center of the canvas after the view appears
            position = CGPoint(
                x: (canvasSize.width - imageSize.width) / 2,
                y: (canvasSize.height - imageSize.height) / 2
            )

            displayLink.start {
                // Update position based on velocity
                position.x += velocity.dx
                position.y += velocity.dy

                // Check if image hits an edge
                if position.x + imageSize.width >= canvasSize.width || position.x <= 0  {
                    // Flip horizontal direction
                    velocity.dx *= -1
                    imageColor = Color.random()
                }

                if position.y + imageSize.height >= canvasSize.height || position.y <= 0 {
                    // Flip vertical direction
                    velocity.dy *= -1
                    imageColor = Color.random()
                }
            }
        }
        .onDisappear {
            displayLink.stop()
        }
        .ignoresSafeArea()
    }
}

extension Color {
    static func random() -> Color {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        return Color(red: red, green: green, blue: blue)
    }
}

#Preview {
    ContentView()
}
