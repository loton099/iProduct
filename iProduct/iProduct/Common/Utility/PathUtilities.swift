//
//  PathUtilities.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 28/06/21.
//

import UIKit

class PathUtilities {
  
  static let imageDirectoryName = "Images"
  
  class func moveFileFromURL(sourceURL: URL, toURL destinationURL: URL) {
    let manager = FileManager.default
    do {
      try manager.moveItem(at: sourceURL, to: destinationURL)
    } catch {
      // If it fails, try creating the directory and attempt the same.
      makeDirectoryAtPath(path: (destinationURL.path as NSString).deletingLastPathComponent)
      do {
        try manager.moveItem(at: sourceURL, to: destinationURL)
      } catch {
      }
    }
  }
  
  class func saveImage(image: UIImage?, toPath path: String?) {
    // Return gracefully if inputs are invalid
    guard image != nil && path != nil && !path!.isEmpty else {return}
    
    let manager = FileManager.default
    if manager.fileExists(atPath: path!) {
      do {
        try manager.removeItem(atPath: path!)
      } catch {
      }
    } else {
      // Create the directory if needed
      makeDirectoryAtPath(path: (path! as NSString).deletingLastPathComponent)
    }
    
    let data = image!.pngData()
    let fileUrl = URL.init(fileURLWithPath: path!)
    
    try! data?.write(to: fileUrl, options: .atomic)
  }
  
  class func loadImageFromPath(path: String) -> UIImage? {
    var image: UIImage?
    let manager = FileManager.default
    if manager.fileExists(atPath: path) {
      image = UIImage.init(contentsOfFile: path)
    }
    return image
  }
  
  class func cachedPathForFile(fileName: String?) -> String? {
    // Check if the file name is valid
    guard fileName != nil && !fileName!.isEmpty else {return nil}
    guard let dirPath = imageCacheDirectoryPath() else {return nil}
    return (dirPath as NSString).appendingPathComponent(fileName!) as String
  }
  
  class func cacheDirectoryPath() -> String? {
    let searchPaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
    return searchPaths.last
  }
  
  class func imageCacheDirectoryPath() -> String? {
    var fullPath: String?
    guard let dirPath = cacheDirectoryPath() else {return fullPath}
    
    fullPath = (dirPath as NSString).appendingPathComponent(imageDirectoryName) as String
    return fullPath;
  }
  
  class func makeDirectoryAtPath(path: String?) {
    guard path != nil else {return}
    
    let fileManager = FileManager.default
    var isDirectory: ObjCBool = false
    let exists = fileManager.fileExists(atPath: path!, isDirectory: &isDirectory)
    if !exists || isDirectory.boolValue {
      do {
        try fileManager.createDirectory(atPath: path!, withIntermediateDirectories: true, attributes: nil)
      } catch {
      }
    }
  }
  
  class func documentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  }
}
