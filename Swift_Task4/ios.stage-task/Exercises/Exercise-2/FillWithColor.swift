import Foundation

final class FillWithColor {
    
    func fillCell(_ newImage: inout [[Int]], _ row: Int, _ column: Int, _ newColor: Int, _ oldColor: Int) {
        if (row >= 0 && row < newImage.count && column >= 0 && column < newImage[0].count && newImage[row][column] == oldColor && newImage[row][column] != newColor) {
            
            if (column < newImage[row].count) {
                newImage[row][column] = newColor
                
                fillCell(&newImage, row + 1, column, newColor, oldColor)
                fillCell(&newImage, row - 1, column, newColor, oldColor)
                fillCell(&newImage, row, column + 1, newColor, oldColor)
                fillCell(&newImage, row, column - 1, newColor, oldColor)
            }
        }
    }
    
    func fillWithColor(_ image: [[Int]], _ row: Int, _ column: Int, _ newColor: Int) -> [[Int]] {
        var newImage = image
        let oldColor = image[row][column]
        
        if image == [] { return [] }
        
        if row < 0 || column < 0 || row >= image.count || column >= image[0].count {
            return image
        }
        
        fillCell(&newImage, row, column, newColor, oldColor)
        
        return newImage
    }
}
