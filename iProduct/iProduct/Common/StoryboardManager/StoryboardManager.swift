//
//  StoryboardManager.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 28/06/21.
//

import Foundation
import UIKit

enum Storyboards: String {
    case Main
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func instantiateVC<T: UIViewController>(_ objectClass: T.Type) -> T {
        return instance.instantiateViewController(withIdentifier: T.storyboardID) as! T
    }
}

enum NibFiles: String {
    
    case ProductListTableViewCell
    
    var instance: UINib {
        return UINib(nibName: self.rawValue, bundle: Bundle.main)
    }
    
    func instantiateVC<T: UIViewController>(_ objectClass: T.Type) -> T? {
        if let vc = instance.instantiate(withOwner: nil, options: nil).first as? T {
            return vc
        }
        return nil
    }
}
