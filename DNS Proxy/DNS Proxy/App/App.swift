//
//  App.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/21/23.
//

import SwiftUI

@main
struct App: SwiftUI.App {
    init() {
        if case .none = Logger.shared {
            Logger.shared = Logger(category: "app")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
