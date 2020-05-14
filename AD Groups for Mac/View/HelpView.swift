//
//  HelpView.swift
//  AD Groups for Mac
//
//  Created by Markus Hölzle on 14.05.20.
//  Copyright © 2020 different.technology. All rights reserved.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack{
            Text("Open help:").bold()
            Button(action: {
                guard let url = URL(string: "https://github.com/different-technology/AD-Groups-for-Mac") else { return }
                NSWorkspace.shared.open(url)
            }) {
                Text("https://github.com/different-technology/AD-Groups-for-Mac")
            }
            Divider().padding(30)
            Text("Copyright © 2020 different.technology")
            Button(action: {
                guard let url = URL(string: "https://different.technology") else { return }
                NSWorkspace.shared.open(url)
            }) {
                Text("https://different.technology")
            }
        }.padding(30)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
