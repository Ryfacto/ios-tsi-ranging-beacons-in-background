//
//  Created by Nicolas VERINAUD on 06/03/2020.
//  Copyright © 2020 ryfacto. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

class IBeaconAdvertiser: NSObject, CBPeripheralManagerDelegate {
  
  override init() {
    super.init()
    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
  }
  
  private var peripheralManager: CBPeripheralManager!
  
  func start() {
    peripheralManager.startAdvertising(peripheralData)
  }
  
  func stop() {
    peripheralManager.stopAdvertising()
  }
  
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    print("Peripheral state : \(peripheral.state.rawValue)")
  }
  
  private var peripheralData: [String : Any]? {
    region.peripheralData(withMeasuredPower: nil) as? [String : Any]
  }
  
  private var region: CLBeaconRegion {
    let uuid = UUID(uuidString: "DD9CD5FA-F2F3-4335-9F57-98EEE8F9DD4C")!
    return CLBeaconRegion(
      beaconIdentityConstraint: CLBeaconIdentityConstraint(uuid: uuid, major: 100, minor: 1),
      identifier: "fr.ryfacto.AwesomeBeacons"
    )
  }
}
