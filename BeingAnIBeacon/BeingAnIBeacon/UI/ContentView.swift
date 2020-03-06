//
//  ContentView.swift
//  BeingAnIBeacon
//
//  Created by Nicolas VERINAUD on 06/03/2020.
//  Copyright © 2020 ryfacto. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var isStarted = false
    
    private let beaconAdvertiser = IBeaconAdvertiser()
    
    var body: some View {
        Button(action: {
            if self.isStarted {
                self.beaconAdvertiser.stop()
            } else {
                self.beaconAdvertiser.start()
            }
            
            self.isStarted.toggle()
        }, label: {
            Text(self.isStarted ? "Stop" : "Start")
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
