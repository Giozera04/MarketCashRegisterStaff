//
//  ScanBoxOverlayView.swift
//  MarketStaffApp
//
//  Created by Giovane Junior on 8/4/25.
//

import Foundation
import SwiftUI

struct ScanBoxOverlayView: View {
    let scanRect: CGRect

    var body: some View {
        GeometryReader { _ in
            let cornerSize: CGFloat = 30
            let lineWidth: CGFloat = 4

            // Top-left
            Path { path in
                path.move(to: CGPoint(x: scanRect.minX, y: scanRect.minY + cornerSize))
                path.addLine(to: CGPoint(x: scanRect.minX, y: scanRect.minY))
                path.addLine(to: CGPoint(x: scanRect.minX + cornerSize, y: scanRect.minY))
            }.stroke(Color.white, lineWidth: lineWidth)

            // Top-right
            Path { path in
                path.move(to: CGPoint(x: scanRect.maxX - cornerSize, y: scanRect.minY))
                path.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.minY))
                path.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.minY + cornerSize))
            }.stroke(Color.white, lineWidth: lineWidth)

            // Bottom-left
            Path { path in
                path.move(to: CGPoint(x: scanRect.minX, y: scanRect.maxY - cornerSize))
                path.addLine(to: CGPoint(x: scanRect.minX, y: scanRect.maxY))
                path.addLine(to: CGPoint(x: scanRect.minX + cornerSize, y: scanRect.maxY))
            }.stroke(Color.white, lineWidth: lineWidth)

            // Bottom-right
            Path { path in
                path.move(to: CGPoint(x: scanRect.maxX - cornerSize, y: scanRect.maxY))
                path.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.maxY))
                path.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.maxY - cornerSize))
            }.stroke(Color.white, lineWidth: lineWidth)
        }
    }
}
