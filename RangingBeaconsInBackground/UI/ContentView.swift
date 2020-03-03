//
//  ContentView.swift
//  RangingBeaconsInBackground
//
//  Created by Nicolas VERINAUD on 03/03/2020.
//  Copyright © 2020 Ryfacto. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  
  @State var isStarted = false
  
  private let beaconsMonitor = BeaconsMonitor()
  
  var body: some View {
    Button(action: {
      if self.isStarted {
        self.beaconsMonitor.stop()
      } else {
        self.beaconsMonitor.start()
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
