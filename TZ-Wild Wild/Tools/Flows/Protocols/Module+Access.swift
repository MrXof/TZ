//
//  Module+Access.swift
//  Hopcharge
//
//  Created by Oleksii Chernysh on 10.02.2021.
//

import Foundation

extension Module {
  
  var serviceProvider: ServiceProviding {
    lookup(self, \.parent, ServiceProviding.self)!
  }
  
  var requestExecutor: RequestExecuting {
    serviceProvider.services.getService()
  }
  
  var errorClassifier: ErrorClassifier {
    serviceProvider.services.getService()
  }
  
  var preferences: Preferences {
    serviceProvider.services.getService()
  }
  
  var objectStore: ObjectStore {
    serviceProvider.services.getService()
  }
  
  var reachability: ReachabilityChecker {
    serviceProvider.services.getService()
  }
  
  var mealPlanner: MealPlanner {
    serviceProvider.services.getService()
  }
  
  var analytics: AnalyticsService {
    serviceProvider.services.getService()
  }
  
  var observablePreferences: ObservablePreferences {
    serviceProvider.services.getService()
  }
  
  var purchaseExecutor: PurchaseExecutor {
    serviceProvider.services.getService()
  }
  
  var localNotificationScheduler: LocalNotificationScheduler {
    serviceProvider.services.getService()
  }
  
  var moneySavingCalculator: MoneySavingCalculator {
    serviceProvider.services.getService()
  }
  
  var carbonDioxideSavingsCalculator: CarbonDioxideSavingsCalculator {
    serviceProvider.services.getService()
  }
  
  var usedProductsCalculator: UsedProductsCalculator {
    serviceProvider.services.getService()
  }
  
  var mealPlanManager: MealPlanManager {
    serviceProvider.services.getService()
  }
  
  var recipeValueCalculator: RecipeValueCalculator {
    serviceProvider.services.getService()
  }
  
}
