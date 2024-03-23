//
//  ContentView.swift
//  DVDScreensaver
//
//  Created by Aryaman Sharda on 3/22/24.
//

import SwiftUI

struct ContentView: View {
    @State private var position: CGPoint = .zero
    @State private var velocity: CGVector = CGVector(dx: 5, dy: 5)
    @State private var imageColor: Color = .green

    private let framesPerSecond: Double = 1 / 30

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
        .onReceive(Timer.publish(every: framesPerSecond, on: .main, in: .common).autoconnect()) { _ in
            // Update position based on velocity
            self.position.x += self.velocity.dx
            self.position.y += self.velocity.dy

            // Check if image hits an edge
            if self.position.x + self.imageSize.width >= canvasSize.width || self.position.x <= 0  {
                // Flip horizontal direction
                self.velocity.dx *= -1
                self.imageColor = Color.random()
            }

            if self.position.y + self.imageSize.height >= canvasSize.height ||  self.position.y <= 0 {
                // Flip vertical direction
                self.velocity.dy *= -1
                self.imageColor = Color.random()
            }
        }
        .onAppear {
            // Set initial position to the center of the canvas after the view appears
            position = CGPoint(
                x: (canvasSize.width - imageSize.width) / 2,
                y: (canvasSize.height - imageSize.height) / 2
            )
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
