//
//  ContentView.swift
//  Alarm Clock
//
//  Created by . . on 05/04/2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var alarmManager: AlarmManager
    @StateObject var memoryGameViewModel: MemoryGameViewModel

    @State private var selectedHour = Calendar.current.component(.hour, from: Date())
    @State private var selectedMinute = Calendar.current.component(.minute, from: Date())
    @State private var isAlarmSet = false
    
    init(alarmManager: AlarmManager) {
        self.alarmManager = alarmManager
        _memoryGameViewModel = StateObject(wrappedValue: MemoryGameViewModel(alarmManager: alarmManager))
    }

    var body: some View {
        VStack {
            HStack {
                Stepper(onIncrement: {
                    selectedHour = (selectedHour + 1) % 24
                }, onDecrement: {
                    selectedHour = (selectedHour + 23) % 24
                }) {
                    Text(String(format: "%02d :", selectedHour)) // Format for two digits
                        .font(.title)
                        .frame(width: 50, alignment: .center)
                }
                .fixedSize()

                Stepper(value: $selectedMinute, in: 0...59) {
                    Text(String(format: "%02d", selectedMinute)) // Format for two digits
                        .font(.title)
                        .frame(width: 50, alignment: .center)
                }
                .fixedSize()
            }
            .padding()

            Button(action: {
                isAlarmSet.toggle()
                if isAlarmSet {
                    alarmManager.setAlarm(hour: selectedHour, minute: selectedMinute)
                } else {
                    alarmManager.cancelAlarm()
                }
            }) {
                Text(isAlarmSet ? "Cancel Alarm" : "Set Alarm")
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Button("Reset to Current Time") {
                let now = Date()
                selectedHour = Calendar.current.component(.hour, from: now)
                selectedMinute = Calendar.current.component(.minute, from: now)
                if isAlarmSet {
                    alarmManager.cancelAlarm()
                    isAlarmSet = false
                }
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .sheet(isPresented: $alarmManager.shouldShowMemoryGame) {
            MemoryGameView(viewModel: memoryGameViewModel)
        }
        .frame(minWidth: 600, minHeight: 400) // Enforce minimum size constraints here
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let previewAlarmManager = AlarmManager()
        ContentView(alarmManager: previewAlarmManager)
    }
}
