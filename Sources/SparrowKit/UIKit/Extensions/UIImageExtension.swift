// The MIT License (MIT)
// Copyright © 2020 Ivan Vorobei (hello@ivanvorobei.by)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit)

import UIKit

public extension UIImage {
    
    // MARK: - Init
    
    /**
     SparrowKit: Create new `UIImage` object by color and size.
     
     Create filled image with specific color.
     
     - parameter color: Color.
     - parameter size: Size.
     */
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        defer {
            UIGraphicsEndImageContext()
        }
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }
        self.init(cgImage: aCgImage)
    }
    
    /**
     SparrowKit: Create `SFSymbols` image with specific configuration.
     
     - parameter name: Name of system image.
     - parameter pointSize: Font size of image.
     - parameter pointSize: Weight of font of image.
     */
    @available(*, deprecated, renamed: "system(name:pointSize:weight:)")
    @available(iOS 13, tvOS 13, *)
    convenience init?(systemName name: String, pointSize: CGFloat, weight: UIImage.SymbolWeight) {
        let configuration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        self.init(systemName: name, withConfiguration: configuration)
    }
    
    /**
     SparrowKit: Create `SFSymbols` image.
     
     - parameter name: Name of system image..
     */
    @available(iOS 13, tvOS 13, *)
    static func system(_ name: String) -> UIImage {
        return UIImage.init(systemName: name) ?? UIImage()
    }
    
    /**
     SparrowKit: Create `SFSymbols` image with specific configuration.
     
     - parameter name: Name of system image.
     - parameter pointSize: Font size of image.
     - parameter pointSize: Weight of font of image.
     */
    @available(iOS 13, tvOS 13, *)
    static func system(_ name: String, pointSize: CGFloat, weight: UIImage.SymbolWeight) -> UIImage {
        let configuration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        return UIImage(systemName: name, withConfiguration: configuration) ?? UIImage()
    }
    
    // MARK: - Helpers
    
    /**
     SparrowKit: Get size of image in bytes.
     */
    var bytesSize: Int {
        return jpegData(compressionQuality: 1)?.count ?? 0
    }
    
    /**
     SparrowKit: Get size of image in kilibytes.
     */
    var kilobytesSize: Int {
        return (jpegData(compressionQuality: 1)?.count ?? 0) / 1024
    }
    
    /**
     SparrowKit: Compress image.
     
     - parameter quality: Factor of compress. Can be in 0...1.
     */
    func compresse(quality: CGFloat = 0.5) -> UIImage? {
        guard let data = jpegData(compressionQuality: quality) else { return nil }
        return UIImage(data: data)
    }
    
    /**
     SparrowKit: Compress data of image.
     
     - parameter quality: Factor of compress. Can be in 0...1.
     */
    func compressedData(quality: CGFloat = 0.5) -> Data? {
        return jpegData(compressionQuality: quality)
    }
    
    // MARK: - Appearance
    
    /**
     SparrowKit: Always original render mode.
     */
    var alwaysOriginal: UIImage {
        return withRenderingMode(.alwaysOriginal)
    }
    
    /**
     SparrowKit: Always original render mode.
     
     - parameter color: Color of image.
     */
    @available(iOS 13.0, tvOS 13.0, *)
    func alwaysOriginal(with color: UIColor) -> UIImage {
        return withTintColor(color, renderingMode: .alwaysOriginal)
    }
    
    /**
     SparrowKit: Always template render mode.
     */
    var alwaysTemplate: UIImage {
        return withRenderingMode(.alwaysTemplate)
    }
    
    /**
     SparrowKit: Get average color of image.
     */
    #if canImport(CoreImage)
    func averageColor() -> UIColor? {
        guard let ciImage = ciImage ?? CIImage(image: self) else { return nil }
        let parameters = [kCIInputImageKey: ciImage, kCIInputExtentKey: CIVector(cgRect: ciImage.extent)]
        guard let outputImage = CIFilter(name: "CIAreaAverage", parameters: parameters)?.outputImage else {
            return nil
        }
        var bitmap = [UInt8](repeating: 0, count: 4)
        let workingColorSpace: Any = cgImage?.colorSpace ?? NSNull()
        let context = CIContext(options: [.workingColorSpace: workingColorSpace])
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        return UIColor(red: CGFloat(bitmap[0]) / 255.0,
                       green: CGFloat(bitmap[1]) / 255.0,
                       blue: CGFloat(bitmap[2]) / 255.0,
                       alpha: CGFloat(bitmap[3]) / 255.0)
    }
    
    /**
     SparrowKit: Resize image to new size with save proportional.
     */
    func resize(newWidth width: CGFloat) -> UIImage {
        let scale = width / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: width, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    #endif
}

#endif
