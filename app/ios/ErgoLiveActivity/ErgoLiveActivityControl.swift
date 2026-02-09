//
//  ErgoLiveActivityControl.swift
//  ErgoLiveActivity
//
//  Created by Anh Tu on 9/2/26.
//

// ControlWidget requires iOS 18.0+.
// This file is intentionally left minimal to avoid
// compilation errors on lower deployment targets.
// The control widget is not needed for Live Activities.

import AppIntents
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 18.0, *)
struct ErgoLiveActivityControl: ControlWidget {
    static let kind: String =
        "com.anhtu.ergolife.ErgoLiveActivity"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: StartTimerIntent()) {
                Label("Start Timer", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("A control that runs a timer.")
    }
}

@available(iOSApplicationExtension 18.0, *)
struct StartTimerIntent: AppIntent {
    static var title: LocalizedStringResource =
        "Start a timer"

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
