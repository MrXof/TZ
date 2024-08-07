//
//  Model+Structure+Display.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 20.02.2021.
//

//import Foundation
//
//extension Module {
//    
//    var path: String {
//      return parentChain()
//        .reversed()
//        .map(\.printDescription)
//        .joined(separator: " / ")
//    }
//    
//    func subtreeStructure() -> String {
//        return subtree()
//    }
//    
//    func printTree() {
//        print(root.subtreeStructure())
//    }
//  
//  var errorHandlingChain: String {
//    "\n" + parentChain()
//      .reversed()
//      .map {
//      ([String(describing: type(of: $0))]// + "\n"
//        +
//        $0.errorPredicates
//        .map(get(\.description))
//        .filter { !$0.isEmpty }
//        ).joined(separator: "\n")
//    }.joined(separator: "\n\n   ^^^   \n\n")
//  }
//    
//}
//
//private extension Module {
//    
//    enum DecorationElement: String {
//        case entryPoint = "──"
//        case middle = "├─"
//        case last = "└─"
//    }
//    
//    func subtree(prefix: String? = nil, decoration: DecorationElement = .entryPoint) -> String {
//        let indent = prefix == nil ? "" : "   "
//        let currentPrefix = (prefix ?? "") + indent
//        var nextIndent = ""
//        
//        if prefix != nil { nextIndent = decoration == .last ? "   " : "   │" }
//        
//        let nextPrefix = (prefix ?? "") + nextIndent
//        let sortedChildren = children.sorted(by: their(\.timestamp))
//        var result = currentPrefix + decoration.rawValue + printDescription + "\n"
//        
//        result += sortedChildren.map {
//            var decoration: DecorationElement
//            if sortedChildren.count == 1 {
//                decoration = .last
//            } else {
//                decoration = $0 == sortedChildren.last ? .last : .middle
//            }
//            return $0.subtree(prefix: nextPrefix, decoration: decoration)
//        }.joined()
//        
//        return result
//    }
//   
//  
//  var printDescription: String {
//    String(describing: type(of: self))
//  }
//  
//}
