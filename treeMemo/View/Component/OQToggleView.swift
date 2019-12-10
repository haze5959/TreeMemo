//
//  OQToggleView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/12/06.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI
import Combine

struct OQToggleView: View {
    @State var model: ToggleModel
    
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        Toggle("", isOn: self.$model.isOn)
            .labelsHidden()
    }
}

struct ToggleModel {
    var isOn: Bool = false {
        willSet {
            self.action(newValue)
        }
    }
    
    let action: (_ isOn: Bool) -> Void
}

struct OQToggleView_Previews: PreviewProvider {
    static var previews: some View {
        OQToggleView(model: ToggleModel(action: { (isOn) in
            print(isOn)
        }))
    }
}
