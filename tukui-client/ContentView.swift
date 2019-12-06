//
//  ContentView.swift
//  tukui-client
//
//  Created by Дарья Жигалко on 06.12.2019.
//  Copyright © 2019 Ilya Zhigalko. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    private let client: TukUIApiClient = TukUIApiClient()

    @State var addons: [Addon] = [Addon]()
    @State var error: Error? = nil
    @State var showError: Bool = false

    var body: some View {
        VStack {
            List(self.addons, id: \.id) { (item: Addon) in
                VStack(alignment: .leading) {
                    Text(item.name).font(.headline)
                }
            }.onAppear() {
                self.client.searchAddons(startsWith: nil, onComplete: self.setAddons, onError: self.onLoadError)
            }
        }.alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(self.error!.localizedDescription), dismissButton: .default(Text("OK")))
        }
    }

    private func setAddons(addons: [Addon]) {
        self.addons = addons
    }

    private func onLoadError(error: Error) {
        self.error = error
        self.showError = true
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
