//
//  ContentView.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/21/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject
    private(set) var store: ContentViewStore
    
    var body: some View {
        VStack(spacing: 16) {
            Text("DNS PROXY")
                .font(.title)
            
            HStack(alignment: .center) {
                Text("Status:")
                
                switch store.isProxyEnabled {
                case .none:
                    Text("Unknown")
                        .foregroundColor(.gray)
                case .some(true):
                    Text("Enabled")
                        .foregroundColor(.green)
                    
                case .some(false):
                    Text("Disabled")
                        .foregroundColor(.red)
                }
            }
            .padding()

            switch store.isProxyEnabled {
            case .none:
                Text("Processing...")
            case .some(true):
                Button("Disable", action: store.disableProxy)
            case .some(false):
                Button("Enable", action: store.enableProxy)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .init())
    }
}

final class ContentViewStore: ObservableObject {
    @Published
    private(set) var isProxyEnabled: Bool? = nil
    
    func enableProxy() {
        
    }
    
    func disableProxy() {
        
    }
}
