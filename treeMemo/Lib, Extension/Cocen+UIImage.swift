//
//  Cocen+UIImage.swift
//  CocenModule
//
//  Created by kwonogyu on 24/06/2019.
//

import UIKit

public enum PathType {
    case document
    case cache
}

public enum ImageExtensionType: String {
    case jpg
    case png
}

public struct ImageFileInDir {
    public var image: UIImage
    public var fileName: String
    
    public init(image: UIImage, fileName: String) {
        self.image = image
        self.fileName = fileName
    }
}

public extension UIImage {
    /**
     해당 사이즈에 맞게 이미지 변환
     - Parameter size: CGSize
     - Returns: UIImage or nil
     */
    func aspectFit(_ size: CGSize) -> UIImage? {
        var newImage: UIImage?
        let originalWidth = self.size.width
        let originalHeight = self.size.height
        var scaleFactor: CGFloat = 0.0
        var newSize: CGSize
        
        if size.width > 0 && size.height > 0 {
            if originalWidth > originalHeight {
                scaleFactor = size.width / originalWidth
            } else {
                scaleFactor = size.height / originalHeight
            }
        } else {
            if size.width > 0 {
                scaleFactor = size.width / originalWidth
            } else if size.height > 0 {
                scaleFactor = size.height / originalHeight
            } else {
                return nil
            }
        }
        
        newSize = CGSize(width: originalWidth * scaleFactor, height: originalHeight * scaleFactor)
        
        UIGraphicsBeginImageContext(newSize)
        
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /**
     해당 사이즈에 이미지가 꽉차게 변환
     - Parameter size: CGSize
     - Returns: UIImage or nil
     */
    func aspectFill(_ size: CGSize) -> UIImage? {
        let sourceImage: UIImage = self
        var newImage: UIImage?
        let imageSize: CGSize = sourceImage.size
        let width: CGFloat = imageSize.width
        let height: CGFloat = imageSize.height
        let targetWidth: CGFloat = size.width
        let targetHeight = size.height
        var scaleFactor: CGFloat = 0.0
        var scaledWidth: CGFloat = targetWidth
        var scaledHeight: CGFloat = targetHeight
        var thumbnailPoint = CGPoint(x: 0.0, y: 0.0)
        
        if !imageSize.equalTo(size) {
            let widthFactor: CGFloat = targetWidth / width
            let heightFactor: CGFloat = targetHeight / height
            
            if widthFactor > heightFactor {
                scaleFactor = widthFactor
            } else {
                scaleFactor = heightFactor
            }
            
            scaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
            } else {
                if widthFactor < heightFactor {
                    thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
                }
            }
        }
        
        UIGraphicsBeginImageContext(size)
        
        var thumbnailRect: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaledWidth
        thumbnailRect.size.height = scaledHeight
        
        sourceImage.draw(in: thumbnailRect)
        
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /**
     해당 사이즈에 가로기준 이미지가 꽉차게 변환
     - Parameter size: CGSize
     - Returns: UIImage or nil
     */
    func widthFit(_ width: CGFloat) -> UIImage? {
        var newImage: UIImage?
        let ratio = width / self.size.width
        let height = self.size.height * ratio
        var newSize: CGSize
        newSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /**
     퍼센트만큼 이미지 크기 감량
     - Parameter percentage: 감량할 용량의 퍼센트
     - Returns: UIImage or nil
     */
    func resizedImage(percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: canvasSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /**
     용량 1MB로 감량
     - Parameter None:
     - Returns: UIImage or nil
     */
    func resizeTo1MB() -> UIImage? {
        guard let imgData = self.pngData() else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imgData.count) / 1000.0
        
        while imageSizeKB > 1000 {
            guard let resizedImage = resizingImage.resizedImage(percentage: 0.8),
                let imageData = resizingImage.pngData() else {
                    return nil
            }
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1000.0
        }
        
        return resizingImage
    }
    
    /**
     이미지 회전
     - Parameter radians: .pi/2가 90도이다.
     - Returns: UIImage or nil
     */
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero,
                             size: self.size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2,
                             y: -self.size.height/2,
                             width: self.size.width,
                             height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /**
     이미지 저장
     - Parameter inDir: PathType
     - Parameter extType: jpg, png
     */
    func saveImageFileIndir(inDir: PathType, name: String, extType: ImageExtensionType) {
        var directory = FileManager.SearchPathDirectory.cachesDirectory
        
        switch inDir {
        case .cache:
            directory = .cachesDirectory
        case .document:
            directory = .documentDirectory
        }
        
        guard let directoryPath = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return
        }
        
        let filename = directoryPath.appendingPathComponent("\(name).\(extType.rawValue)")
        
        switch extType {
        case .jpg:
            if let data = self.jpegData(compressionQuality: 0.8) {
                try? data.write(to: filename)
            }
        case .png:
            if let data = self.pngData() {
                try? data.write(to: filename)
            }
        }
    }
    
    /**
     이미지 불러오기
     - Parameter inDir: PathType
     - Parameter name: 이미지명
     - Parameter extType: jpg, png
     - Returns: UIImage or nil
     */
    func loadImageFileIndir(inDir: PathType, name: String, extType: ImageExtensionType) -> UIImage? {
        var directory = FileManager.SearchPathDirectory.cachesDirectory
        
        switch inDir {
        case .cache:
            directory = .cachesDirectory
        case .document:
            directory = .documentDirectory
        }
        
        guard let directoryPath = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return nil
        }
        
        let filename = directoryPath.appendingPathComponent("\(name).\(extType.rawValue)")
        
        return UIImage(contentsOfFile: filename.path)
    }
    
    /**
     이미지 불러오기
     - Parameter inDir: PathType
     - Parameter extType: jpg, png
     - Parameter filter: 이미지명 필터
     - Returns: [ImageFileInDir]
     */
    func loadAllImageFromIndir(inDir: PathType, extType: ImageExtensionType, filter: String = "") -> [ImageFileInDir] {
        var directory = FileManager.SearchPathDirectory.cachesDirectory
        
        switch inDir {
        case .cache:
            directory = .cachesDirectory
        case .document:
            directory = .documentDirectory
        }
        
        guard let directoryPath = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return [ImageFileInDir]()
        }
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: directoryPath,
                                                                                includingPropertiesForKeys: nil)
            let imageFiles = directoryContents.filter { $0.pathExtension == extType.rawValue }.filter { file in
                if filter != "" {
                    return file.lastPathComponent.contains(filter)
                } else {
                    return true
                }
            }
            
            return imageFiles.compactMap { imagePath in
                if let image = UIImage(contentsOfFile: imagePath.path) {
                    return ImageFileInDir(image: image, fileName: imagePath.lastPathComponent)
                } else {
                    return nil
                }
                }.sorted(by: { $0.fileName < $1.fileName })
        } catch {
            return [ImageFileInDir]()
        }
    }
}
