//
//  StartView.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 26.05.21.
//  Copyright © 2021 different.technology. All rights reserved.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        VStack {
            Text("")
                .font(.footnote)
                .frame(maxHeight: .infinity, alignment: .top)
            Text("AD Groups for Mac").font(.largeTitle)
            Text("Manage your Active Directory groups.")
            Text("Copyright © 2020 different.technology by Markus Hölzle")
                .font(.footnote)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
