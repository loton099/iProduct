//
//  NetworkImageView.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 28/06/21.
//


import UIKit

typealias LoadImageCompletionHandler = ( (Bool) -> Void)

class NetworkImageView: UIImageView {
  
  private var cacheHandle: Cancellable?
  var imageURL: String?
  
  override var image: UIImage? {
    didSet {
      self.reset()
    }
  }
  
  func reset() {
    self.cacheHandle?.cancel()
    self.cacheHandle = nil
  }
  
  func loadImageWithURL(url: String?, placeHolderImage: UIImage?, completion:LoadImageCompletionHandler? = nil) {
    self.imageURL = url
    startLoadingImageWithPlaceHolderImage(placeHolderImage: placeHolderImage, completion: completion)
  }
  
  @objc private func startLoadingImageWithPlaceHolderImage(placeHolderImage: UIImage?, completion:LoadImageCompletionHandler?) {
    // Set the place holder image. This in-turn cancells the previous request
    self.image = placeHolderImage
    
    let url = self.imageURL
    let handle = ImageCache.sharedCache.imageForURL(url: url) { image, error in
      self.cacheHandle = nil
      if url == self.imageURL {
        if image != nil {
          self.image = image
          completion?(true)
        }
      }
    }
    self.cacheHandle = handle
  }
}
