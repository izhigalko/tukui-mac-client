//
// Created by Дарья Жигалко on 06.12.2019.
// Copyright (c) 2019 Ilya Zhigalko. All rights reserved.
//

import Foundation
import SwiftUI

struct AddonRow: View {
    var addon: Addon

    var body: some View {
        Text(addon.name)
    }
}
