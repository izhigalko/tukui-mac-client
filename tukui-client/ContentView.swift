//
//  ContentView.swift
//  tukui-client
//
//  Created by Дарья Жигалко on 06.12.2019.
//  Copyright © 2019 Ilya Zhigalko. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var addons: [Addon] = [Addon]()
    @State var error: Error? = nil
    @State var showError: Bool = false
    
    let ctx: ApplicationContext!

    init(_ ctx: ApplicationContext!) {
        self.ctx = ctx
    }
    
    var body: some View {
        VStack {
            List(self.addons, id: \.id) { (item: Addon) in
                VStack(alignment: .leading) {
                    HStack {
                        Text(self.isAddonInstalled(item)).font(.headline)
                        Text(item.name).font(.headline)
                    }
                }
            }.onAppear() {
                self.ctx.setup(self.onError)
                self.ctx.api.getAddonsWithCore(self.setAddons, self.onError)
            }
        }.alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(self.error!.localizedDescription), dismissButton: .default(Text("OK")))
        }
    }

    private func setAddons(addons: [Addon]) {
        self.addons = addons
    }

    private func onError(error: Error) {
        self.error = error
        self.showError = true
    }
    
    private func isAddonInstalled(_ addon: Addon) -> String {
        let isInstalled = self.ctx.installed.isAddonInstalled({ localAddon in
            return localAddon.name == addon.name
        })
        
        return isInstalled ? "Yes" : "No"
    }
}
