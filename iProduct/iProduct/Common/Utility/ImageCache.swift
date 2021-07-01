//
//  ImageCache.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 28/06/21.
//
/**
 ImageCache class provides an infrastructure to fetch images asynchronously. This class abstracts the details of image fech.
 
 --Cache--
 When requested,
 -- fetches from memory cache in the first pass
 -- If a miss, fetches from disk cache
 -- If a miss, feteches from the network asynchronously
 
 Usage
 ImageCache.sharedCache.imageForURL(urlOfTheImage) { image, error in
 //use the returned image
 }
 
 --Memory management--
 Removes all the chached imeages from the memory when there is a low memory warning
 Provides a way of purging cache - both in-memory and disk
 
 Usage
 ImageCache.sharedCache.purge()
 
 --Cancel handle--
 If you wish to cancel the fetch for any reason, the image request API returns a handle to an object of type Cancellable
 You can use this handle later to cancel the fetch request
 
 Tip: This would be useful while implementing table views or collection views, when the user swipes quickly through the list, we can prioritize the load to fetch only visible items, discarding the rows that shown intermediately.
 
 Usage
 let handle = ImageCache.sharedCache.imageForURL(<#urlOfTheImage#>) { image, error in
 //code to use the returned image
 }
 
 // ... later in code
 
 handle.cancel()
 
 */

import UIKit

typealias CompletionHandler = ((UIImage?, Error?) -> Void)
typealias ProgressHandler = ((_ bytesUpto: Int64, _ bytesTotal:Int64) -> Void)

/**
 Returns the image in the main thread if the images are available in memory or in disk.
 Otherwise, creates a DownloadWatchman object to download the image from the network and informs the requester via main thread
 */
public class ImageCache: NSObject, URLSessionDownloadDelegate {
  
  private let memoryCache: NSCache<AnyObject, AnyObject>    // Holds the chached images in memory
  private var downloaderSession: URLSession?
  private var tasks: Set<NetworkTask>   // References to each individual image request.
  
  // MARK: - Singleton
  static let sharedCache = ImageCache()
  
  private override init() {
    memoryCache = NSCache()
    tasks = Set<NetworkTask>()
    
    super.init()
    
    downloaderSession = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    
    // Register for the memory warning notification
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
  }
  
  // Cleanup
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  private func cancelAllTasks() {
    self.tasks.forEach { task in
      task.cancel()
    }
  }
  
  // MARK: - Low memory
  @objc func didReceiveMemoryWarning(notif: NSNotification) {
    memoryCache.removeAllObjects()
  }
  
  // MARK: - Public Interfaces
  // Sets the cache limit to a specified limit. Default is 0 (no limit); managed by OS
  public func setCacheLimit(limit: Int) {
    memoryCache.countLimit = limit
  }
  
  // Purges the cache.
  // force: If this parameter is yes, removes all images written to the persistent store as well. Default is false
  public func purge(force: Bool = false) {
    cancelAllTasks()
    memoryCache.removeAllObjects()
    if force == true {
      do {
        guard let cachePath = PathUtilities.imageCacheDirectoryPath() else {return}
        try FileManager.default.removeItem(atPath: cachePath)
      } catch {
        debugPrint("Error occurred while clearing cache.")
      }
    }
  }
  
  // Clears the hard cached items (persistant images) if they are more than "seconds" seconds old.
  // Default value is 1 day
  public func purgeItemsIfOlderThan(seconds: TimeInterval = 86400) {
    memoryCache.removeAllObjects()
    let manager = FileManager.default
    guard let cachePath = PathUtilities.imageCacheDirectoryPath() else {return}
    guard let dirEnum = manager.enumerator(atPath: cachePath) else {return}
    while let file = dirEnum.nextObject() {
      guard let attribs = dirEnum.fileAttributes else {continue}
      
      let creationStamp = (attribs[FileAttributeKey.creationDate]! as AnyObject).timeIntervalSince1970
      let nowStamp = NSDate().timeIntervalSince1970
      if fabs(nowStamp - creationStamp!) > seconds {
        let filePath = (cachePath as NSString).appendingPathComponent(file as! String)
        if manager.fileExists(atPath: filePath) {
          do {
            try manager.removeItem(atPath: filePath)
          } catch {
            debugPrint("Error removing file at path: \(filePath)")
          }
        }
      }
    }
  }
  
  /*
   * Use this method for downloading images asynchronously without requiring the timely progress
   Returns the handle for the Cancellable object in case you want to cancel the fetch.
   This would be helpful in case the item is queued for fetching from internet.
   
   Returns the Cancellable object if the fetch is from the server. Returns nil otherwise.
   */
  func imageForURL(url: String?, completion: CompletionHandler?) -> Cancellable? {
    return self.imageForURL(url: url, progress: nil, completion: completion)
  }
  
  /*
   * Use this method for downloading images asynchronously with a timely progress through the progress block
   */
  func imageForURL(url: String?, progress: ProgressHandler?, completion: CompletionHandler?) -> Cancellable? {
    
    func informCompletion(cachedImage: UIImage?, errorOccurred: Error?) {
      if completion != nil {
        DispatchQueue.main.async {
          completion!(cachedImage, errorOccurred)
        }
      }
    }
    
    // Inform the requester immediatley and exit gracefully
    guard url != nil && !url!.isEmpty else {
      informCompletion(cachedImage: nil, errorOccurred: nil)
      return nil
    }
    
    // generate a unique key for the URL
    let key = url!.sha1()
    
    // Check in-meomry cache first
    if let memCachedImage = self.memoryCache.object(forKey: key as AnyObject) as? UIImage {
      debugPrint("Hit MemCache☺️: \(key)")
      informCompletion(cachedImage: memCachedImage, errorOccurred: nil)
      return nil
    }
    
    // Check disk cache
    let cachedPath = PathUtilities.cachedPathForFile(fileName: key)
    if let diskCachedImage = PathUtilities.loadImageFromPath(path: cachedPath!) {
      debugPrint("Hit DiskCache😬: \(key)")
      // add to in-memory cache
      memoryCache.setObject(diskCachedImage, forKey: key as AnyObject)
      informCompletion(cachedImage: diskCachedImage, errorOccurred: nil)
      return nil;
    }
    
    for task in self.tasks where task.taskDescription == key {
      if task.state == .running {
        return task.attachProgressHandler(progress: progress, andCompletionHandler: completion)
      }
    }
    
    // Create a URL from the string we get.
    let escapedURL = url?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    let imageURL = URL.init(string: escapedURL!)
    guard imageURL != nil else {
      // If the converting from string to url fails, report and return.
      informCompletion(cachedImage: nil, errorOccurred: nil)
      return nil
    }
    
    // We reached here which is sad. We'll have to get it from server now.
    let task = NetworkTask.init(withTask: self.downloaderSession!.downloadTask(with: imageURL!))
    task.taskDescription = key
    let handler = task.attachProgressHandler(progress: progress, andCompletionHandler: completion)
    
    self.tasks.insert(task)
    
    task.resume()
    return handler
  }
  
  private func taskWithIdentifier(identifier: String?) -> NetworkTask? {
    guard identifier != nil else {
      return nil
    }
    
    for task in self.tasks where task.taskDescription == identifier {
      return task
    }
    return nil
  }
}

extension ImageCache {
  // MARK: -
  private func informCompletionsForTask(task: URLSessionTask, cachedImage: UIImage?, errorOccurred: Error?) {
    DispatchQueue.main.async {
      guard let networkTask = self.taskWithIdentifier(identifier: task.taskDescription) else {
        return
      }
      
      networkTask.handles.forEach {$0.completionHandler?(cachedImage, errorOccurred)}
      networkTask.removeAllHandles()
    }
  }
  
  private func informProgressesForTask(task: URLSessionTask, bytesUpto: Int64, bytesTotal: Int64) {
    DispatchQueue.main.async {
      guard let networkTask = self.taskWithIdentifier(identifier: task.taskDescription) else {
        return
      }
      networkTask.handles.forEach {$0.progressHandler?(bytesUpto, bytesTotal)}
    }
  }
}

extension ImageCache {
  public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    guard let filePath = PathUtilities.cachedPathForFile(fileName: downloadTask.taskDescription) else {
      informCompletionsForTask(task: downloadTask, cachedImage: nil, errorOccurred: nil)
      return
    }
    
    // Write to disk cache
    let destinationURL = URL(fileURLWithPath: filePath)
    PathUtilities.moveFileFromURL(sourceURL: location, toURL: destinationURL)
    
    guard let image = PathUtilities.loadImageFromPath(path: filePath) else {
      informCompletionsForTask(task: downloadTask, cachedImage: nil, errorOccurred: nil)
      return
    }
    
    debugPrint("Oh no! From server😳: \(downloadTask.taskDescription!)")
    
    // Store it in the memory cache
    DispatchQueue.main.async {
      self.memoryCache.setObject(image, forKey: downloadTask.taskDescription! as AnyObject)
    }
    // Success. Return the image obtained.
    informCompletionsForTask(task: downloadTask, cachedImage: image, errorOccurred: nil)
  }
  
  public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    informProgressesForTask(task: downloadTask, bytesUpto: totalBytesWritten, bytesTotal: totalBytesExpectedToWrite)
  }
  
  // This will be called once the session is complete, irrespective of there is any error or not.
  // We'll clean up here.
  public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if error != nil {
      informCompletionsForTask(task: task, cachedImage: nil, errorOccurred: error! as Error)
      debugPrint("Reason: \(error!)")
    }
    
    DispatchQueue.main.async {
      guard let networkTask = self.taskWithIdentifier(identifier: task.taskDescription) else {
        return
      }
      self.tasks.remove(networkTask)
    }
  }
}

private class Handle : NSObject, Cancellable {
  private weak var handler: Handler? // Reference to the parent class
  
  var completionHandler: CompletionHandler?
  var progressHandler: ProgressHandler?
  
  init(withHandler handler: Handler) {
    self.handler = handler
  }
  
  func cancel() {
    handler?.handle(handle: self)
  }
}

// MARK: - Weight lifter class
/*
 * Handles the download
 */
private class NetworkTask: NSObject, Cancellable, Handler {
  
  var underlyingTask: URLSessionTask
  // Set of handles in case of multiple requests with same url
  var handles = Set<Handle>()
  var taskDescription: String? {
    didSet {
      self.underlyingTask.taskDescription = taskDescription
    }
  }
  var state: URLSessionTask.State {
    get {
      return self.underlyingTask.state
    }
  }
  
  init(withTask task:URLSessionTask) {
    self.underlyingTask = task
  }
  
  func removeAllHandles() {
    self.handles.removeAll()
  }
  
  fileprivate func handle(handle: Handle) {
    self.handles.remove(handle)
    
    if self.handles.count == 0 {
      self.cancel()
    }
  }
  
  func attachProgressHandler(progress: ProgressHandler?, andCompletionHandler completion: CompletionHandler?) -> Cancellable? {
    let handle = Handle.init(withHandler: self)
    
    if progress != nil {
      handle.progressHandler = progress!
    }
    
    if completion != nil {
      handle.completionHandler = completion!
    }
    
    self.handles.insert(handle)
    return handle
  }
  
  func resume() {
    self.underlyingTask.resume()
  }
  
  func cancel() {
    self.underlyingTask.cancel()
    
    if self.underlyingTask.state == .canceling {
      
    }
  }
}

// MARK: - Used to cancel a cache request which is a miss and yet to be downloaded from internet
public protocol Cancellable {
  func cancel()
}

private protocol Handler : AnyObject {
  func handle(handle: Handle)
}
