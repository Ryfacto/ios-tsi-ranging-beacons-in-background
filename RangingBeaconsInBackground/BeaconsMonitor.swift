//
//  BeaconsMonitor.swift
//  RangingBeaconsInBackground
//
//  Created by Nicolas VERINAUD on 03/03/2020.
//  Copyright © 2020 Ryfacto. All rights reserved.
//

import AVFoundation
import CoreLocation
import Foundation

class BeaconsMonitor: NSObject, CLLocationManagerDelegate {
  
  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.showsBackgroundLocationIndicator = true
  }
  
  private var isStarted = false
  private let locationManager = CLLocationManager()
  private let beaconIdentity = CLBeaconIdentityConstraint(uuid: UUID(uuidString: "DD9CD5FA-F2F3-4335-9F57-98EEE8F9DD4C")!)
  private lazy var region = CLBeaconRegion(uuid: beaconIdentity.uuid, identifier: "Square")
  private let speechSynthesizer = AVSpeechSynthesizer()
  private var lastSpeakDate = Date.distantPast
  
  func toggle() {
    if isStarted {
      stop()
    } else {
      start()
    }
  }
  
  func start() {
    isStarted = true
    let authorization = CLLocationManager.authorizationStatus()
    if authorization == .notDetermined {
      locationManager.requestAlwaysAuthorization()
    } else if isAuthorized(authorization) {
      beginRanging()
    }
  }
  
  func stop() {
    isStarted = false
    endRanging()
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if isAuthorized(status) && isStarted {
      beginRanging()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    say("Did enter region \(region.identifier).")
    manager.requestState(for: region)
  }
  
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    say("Did exit region \(region.identifier).")
    manager.requestState(for: region)
  }
  
  func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
    print("\(state) region '\(region.identifier)'.")
    if state == .inside {
      beginRangingBeacons()
    } else if state == .outside {
      endRangingBeacons()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
    let message = "\(beacons.count) beacons found in region \(region.identifier)."
    print(message)
    print("Beacons are : \(beacons).")
    sayButNotTooOften(message)
  }
  
  private func isAuthorized(_ authorization: CLAuthorizationStatus) -> Bool {
    authorization == .authorizedWhenInUse || authorization == .authorizedAlways
  }
  
  private func beginRanging() {
    activateAudioSession()
    locationManager.startUpdatingLocation()
    locationManager.startMonitoring(for: region)
    locationManager.requestState(for: region)
  }
  
  private func endRanging() {
    terminateAudioSession()
    locationManager.stopUpdatingLocation()
    locationManager.stopMonitoring(for: region)
    endRangingBeacons()
  }
  
  private func activateAudioSession() {
    try? AVAudioSession.sharedInstance().setCategory(.playback)
    try? AVAudioSession.sharedInstance().setActive(true, options: [])
  }
  
  private func terminateAudioSession() {
    try? AVAudioSession.sharedInstance().setActive(false, options: [])
  }
  
  private func beginRangingBeacons() {
    locationManager.startRangingBeacons(satisfying: beaconIdentity)
  }
  
  private func endRangingBeacons() {
    locationManager.stopRangingBeacons(satisfying: beaconIdentity)
  }
  
  private func sayButNotTooOften(_ message: String) {
    if -lastSpeakDate.timeIntervalSinceNow > 10 {
      lastSpeakDate = Date()
      say(message)
    }
  }
  
  private func say(_ message: String) {
    let utterance = AVSpeechUtterance(string: message)
    utterance.voice = AVSpeechSynthesisVoice(language: "en_US")
    speechSynthesizer.speak(utterance)
    print(message)
  }
}

extension BeaconsMonitor {
  
  func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
    print("Did fail ranging for \(beaconConstraint), error = \(error).")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Did fail with error \(error).")
  }
  
  func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    print("Did start monitoring for \(region).")
  }
  
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("Monitoring did fail for region \(String(describing: region)), error = \(error).")
  }
}

extension CLRegionState: CustomDebugStringConvertible {
  
  public var debugDescription: String {
    switch self {
      case .inside: return "Inside"
      case .outside: return "Outside"
      case .unknown: return "Unknown"
    }
  }
}
