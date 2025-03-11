//
//  AlarmManager.swift
//  Alarm Clock
//
//  Created by . . on 05/04/2024.
//

import Foundation
import AVFoundation

class AlarmManager: ObservableObject {
    @Published var isAlarmActive: Bool = false
    @Published var shouldShowMemoryGame: Bool = false
    var alarmTime: Date?
    var wristwatchPlayer: AVAudioPlayer?
    var bellPlayer: AVAudioPlayer?

    // New Timer properties to manage sound playback durations
    var wristwatchTimer: Timer?
    var bellTimer: Timer?
    var volumeAdjustTimer: Timer?
    var initialVolume: Float = 0.0 // Holds the initial volume
    var volumeCheckTimer: Timer?
    let targetVolume: Int = 100 // Target volume level
        let duration: TimeInterval = 10 // Duration over which to increase volume initially
        let checkInterval: TimeInterval = 2 // Interval to check and adjust volume if needed

    init() {
        setupAudioPlayers()
    }
    
    deinit {
        // Invalidate timers when the instance is deinitialized to avoid memory leaks
        wristwatchTimer?.invalidate()
        bellTimer?.invalidate()
    }
    
    func alarmDidGoOff() {
        NotificationCenter.default.post(name: NSNotification.Name("AlarmDidGoOff"), object: nil)
    }
    
    func stopEnsuringVolume() {
        // Invalidate the timer when the alarm is turned off or game ends
        volumeCheckTimer?.invalidate()
    }
    
    func ensureMaximumVolume(withInitialDelay delay: TimeInterval = 5.0) { // Default delay of 5 seconds
        // Cancel any existing timer to avoid overlapping timers
        volumeCheckTimer?.invalidate()
        
        // Start the timer after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.volumeCheckTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                let script = "osascript -e \"set volume output volume 100\""
                self?.executeCommand(script)
            }
        }
    }
    
    func graduallyIncreaseVolumeIfNeeded() {
        let initialVolume: Int = 30 // Minimal audible level
        let targetVolume: Int = 100 // Maximum volume level
        let increments = 14 // Number of steps to reach the target volume
        let totalDuration: TimeInterval = 10.0 // Duration over which to increase volume
        let timePerStep = totalDuration / Double(increments)

        // Set initial volume to ensure it's audible
        executeCommand("osascript -e \"set volume output volume \(initialVolume)\"")
        
        // Gradually increase to target volume
        for step in 1...increments {
            DispatchQueue.main.asyncAfter(deadline: .now() + timePerStep * Double(step)) {
                let volumeStep = initialVolume + ((targetVolume - initialVolume) * step / increments)
                let script = "osascript -e \"set volume output volume \(volumeStep)\""
                self.executeCommand(script)
            }
        }
    }

    func executeCommand(_ command: String) {
        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = pipe
        process.arguments = ["-c", command]
        process.launchPath = "/bin/zsh"
        process.launch()
    }
    
    // Placeholder for a method to retrieve the current system volume level
        private func getSystemVolume() -> Int {
            // This would need to be implemented based on available APIs or scripts
            return 0 // Placeholder
        }

    func snoozeAlarm() {
        print("snoozeAlarm called")
        let snoozeTime = 15.0 * 60.0
        
        DispatchQueue.main.async {
            // Invalidate any existing snooze timers to ensure there's only one active snooze
            self.wristwatchTimer?.invalidate()
            
            self.wristwatchTimer = Timer.scheduledTimer(withTimeInterval: snoozeTime, repeats: false) { [weak self] _ in
                self?.triggerAlarm()
            }
        }
    }
    
    func cancelSnooze() {
            wristwatchTimer?.invalidate()
        }
    
    func turnOffAlarm() {
        print("Turning off alarm...")
        
        // Stop both audio players
        wristwatchPlayer?.stop()
        bellPlayer?.stop()
        
        // Invalidate and nullify the timers to prevent them from firing again
        wristwatchTimer?.invalidate()
        bellTimer?.invalidate()
        wristwatchTimer = nil
        bellTimer = nil

        // Update state to reflect that the alarm is no longer active
        isAlarmActive = false
        shouldShowMemoryGame = false
        alarmTime = nil
        
        print("Alarm turned off")
        snoozeAlarm()
    }
    
    func setAlarm(hour: Int, minute: Int) {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0 // Ensure the alarm triggers at the start of the minute
        
        guard let alarmTime = calendar.date(from: components) else { return }
        
        self.alarmTime = alarmTime
        
        // Compare the alarmTime with the current time
        if alarmTime <= now {
            // If the alarmTime is now or in the past, trigger the alarm immediately
            triggerAlarm()
        } else {
            // Schedule the alarm for a future time
            let timeInterval = alarmTime.timeIntervalSinceNow
            Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
                self?.triggerAlarm()
            }
        }
    }

    func triggerAlarm() {
        DispatchQueue.main.async {
            // self.adjustVolumeGradually()
            self.graduallyIncreaseVolumeIfNeeded()
            
            // Other alarm activation logic here, such as starting sound playback
            self.isAlarmActive = true
            self.shouldShowMemoryGame = true
            self.playSound()
        }
    }

    func setupAudioPlayers() {
        guard let wristwatchURL = Bundle.main.url(forResource: "Alarm Wristwatch", withExtension: "aif"),
              let bellURL = Bundle.main.url(forResource: "Bell Fire Alarm", withExtension: "aif") else {
            print("Audio files not found in app bundle")
            return
        }

        do {
            wristwatchPlayer = try AVAudioPlayer(contentsOf: wristwatchURL)
            bellPlayer = try AVAudioPlayer(contentsOf: bellURL)
            wristwatchPlayer?.numberOfLoops = -1 // Loop indefinitely
            bellPlayer?.numberOfLoops = -1 // For consistent behavior, consider looping the bell sound as well
        } catch {
            print("Could not load file: \(error)")
        }
    }

    func playSound() {
            // Initially start with the wristwatch sound
            startWristwatchSound()
        }
    
    func startWristwatchSound() {
            // Ensure the bell sound is stopped before starting the wristwatch sound
            bellPlayer?.stop()
            bellTimer?.invalidate()

            wristwatchPlayer?.play()
            
            // Schedule wristwatch sound to play for 30 seconds
            wristwatchTimer = Timer.scheduledTimer(withTimeInterval: 300.0, repeats: false) { [weak self] _ in
                self?.startBellSound()
            }
        }
        
        func startBellSound() {
            // Ensure the wristwatch sound is stopped before starting the bell sound
            wristwatchPlayer?.stop()
            wristwatchTimer?.invalidate()

            bellPlayer?.play()
            
            // Schedule bell sound to play for 10 seconds
            bellTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { [weak self] _ in
                self?.startWristwatchSound()
            }
        }

    func cancelAlarm() {
        print("Cancelling alarm and snooze...")
        
        // Stop audio players
        wristwatchPlayer?.stop()
        bellPlayer?.stop()
        
        // Invalidate timers for audio and snooze
        wristwatchTimer?.invalidate()
        bellTimer?.invalidate()
        volumeCheckTimer?.invalidate() // Assuming this timer is used for snooze

        // Nullify timers
        wristwatchTimer = nil
        bellTimer = nil
        volumeCheckTimer = nil // Cancel snooze
        
        // Update state to reflect the alarm and snooze are no longer active
        isAlarmActive = false
        shouldShowMemoryGame = false
        alarmTime = nil
    }
}
