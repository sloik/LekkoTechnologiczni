
#if canImport(UIKit)

import UIKit

public func rotated(deg: CGFloat) -> (UIImage) -> UIImage {
    return { image in
        return rotated(image, deg: deg)
    }
}

public let rotatedLeft  = rotated(deg: -90)
public let rotatedRight = rotated(deg:  90)

public func toRadians(_ deg: CGFloat) -> CGFloat {
    return deg * CGFloat.pi / 180
}

public func rotate(_ deg: CGFloat) -> (CGSize) -> CGSize {
    return { size in
        return
            CGRect(origin: .zero,size: size)
                .applying( CGAffineTransform(rotationAngle: toRadians(deg)) )
                .integral
                .size
    }
}

public func rotated(_ oldImage: UIImage, deg degrees: CGFloat) -> UIImage {

    //Calculate the size of the rotated view's containing box for our drawing space
    let rotatedSize =   rotate(degrees)(oldImage.size)


    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize)
    defer { UIGraphicsEndImageContext() }

    let bitmap: CGContext = UIGraphicsGetCurrentContext()!
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    bitmap.translateBy(x: rotatedSize.width / 2,
                       y: rotatedSize.height / 2)

    //Rotate the image context
    bitmap.rotate(by:  toRadians(degrees) )

    //Now, draw the rotated/scaled image into the context
    bitmap.scaleBy(x: 1.0, y: -1.0)
    bitmap.draw(oldImage.cgImage!,
                in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2,
                           width: oldImage.size.width,
                           height: oldImage.size.height))

    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!


    return newImage
}

#endif
