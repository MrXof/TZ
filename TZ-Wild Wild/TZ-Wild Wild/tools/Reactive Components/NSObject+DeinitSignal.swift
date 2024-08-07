//
//  NSObject+DeinitSignal.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 16.05.2021.
//

import Foundation

extension NSObject {
  
  var deinitSignal: Pipe<Void> {
    deinitNotifier.signal
  }
  
}

private extension NSObject {
  
  private static var notifierKey: UInt8 = 0
  
  var deinitNotifier: DeinitNotifier {
    if let notifier = objc_getAssociatedObject(self, &NSObject.notifierKey) as? DeinitNotifier {
      return notifier
    } else {
      let notifier = DeinitNotifier()
      objc_setAssociatedObject(self, &NSObject.notifierKey,
                               notifier,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return notifier
    }
  }
  
}

private final class DeinitNotifier {
  
  let signal = Pipe<Void>()
  
  deinit {
    signal.send(())
  }
  
}
