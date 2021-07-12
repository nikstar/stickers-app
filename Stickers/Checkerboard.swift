//
//  Сруслукищфкв.swift
//  Stickers
//
//  Created by  nikstar on 29.06.2021.
//

import SwiftUI

struct Checkerboard: Shape {
    
    let columns: Int

    func path(in rect: CGRect) -> Path {
        
        let size = rect.width / CGFloat(columns)
//        let rows = Int((rect.height / size).rounded(.up))
        let rows = columns
        let offset = rect.height - size * CGFloat(rows)
        
        var path = Path()
        
        // loop over all rows and columns, making alternating squares colored
        for row in 0..<rows {
            for column in 0..<columns {
                if (row + column) % 2 == 0 {
                    // this square should be colored; add a rectangle here
                    let startX = size * CGFloat(column)
                    let startY = offset + size * CGFloat(row)

                    let rect = CGRect(x: startX, y: startY, width: size, height: size)
                    path.addRect(rect)
                }
            }
        }

        return path
    }
}

