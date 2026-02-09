//
//  ErgoLiveActivityLiveActivity.swift
//  ErgoLiveActivity
//
//  Created by Anh Tu on 9/2/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

// Must match the struct in the live_activities Flutter plugin.
struct LiveActivitiesAppAttributes:
    ActivityAttributes, Identifiable
{
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable {
        var appGroupId: String
    }

    var id = UUID()
}

let sharedDefault = UserDefaults(
    suiteName: "group.com.anhtu.ergolife"
)!

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        "\(id)_\(key)"
    }
}

// MARK: - ErgoLife Brand Colors

private enum Ergo {
    static let blue = Color(
        red: 13 / 255.0, green: 89 / 255.0, blue: 242 / 255.0
    )
    static let orange = Color(
        red: 255 / 255.0, green: 107 / 255.0, blue: 0 / 255.0
    )
    static let green = Color(
        red: 16 / 255.0, green: 185 / 255.0, blue: 129 / 255.0
    )
    static let bgDark = Color(
        red: 15 / 255.0, green: 17 / 255.0, blue: 21 / 255.0
    )
    static let surfaceDark = Color(
        red: 26 / 255.0, green: 29 / 255.0, blue: 36 / 255.0
    )
    static let textSub = Color(
        red: 156 / 255.0, green: 166 / 255.0,
        blue: 186 / 255.0
    )
}

// MARK: - Widget Entry Point

@available(iOSApplicationExtension 16.1, *)
struct ErgoLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: LiveActivitiesAppAttributes.self
        ) { context in
            // Lock Screen banner
            LockScreenView(context: context)
        } dynamicIsland: { context in
            let attrs = context.attributes
            let isPaused = sharedDefault.bool(
                forKey: attrs.prefixedKey("isPaused")
            )
            let taskName = sharedDefault.string(
                forKey: attrs.prefixedKey("taskName")
            ) ?? "Session"
            let target = sharedDefault.integer(
                forKey: attrs.prefixedKey("targetSeconds")
            )

            // Dynamic Island Expanded Layout:
            //
            // .leading and .trailing are NARROW strips beside
            // the TrueDepth camera — only fit a single icon or
            // short text. All meaningful content goes in .bottom
            // which spans the full width below the camera.
            //
            // ┌──────────────────────────────────┐
            // │  🏃 (leading) ◻️camera◻️ 01:11 (trailing) │
            // │──────────────────────────────────│
            // │  Vacuuming                       │ ← .bottom
            // │  ════════════ progress ══════════│
            // │  🟢 In Progress      Target 20:00│
            // └──────────────────────────────────┘

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(
                        systemName: isPaused
                            ? "pause.fill"
                            : "figure.run"
                    )
                    .font(
                        .system(
                            size: 20, weight: .semibold
                        )
                    )
                    .foregroundColor(
                        isPaused
                            ? Ergo.orange : Ergo.blue
                    )
                    .frame(maxHeight: .infinity)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    SessionTimer(
                        context: context, size: .medium
                    )
                    .frame(maxHeight: .infinity)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(
                        alignment: .leading, spacing: 6
                    ) {
                        // Task name
                        Text(taskName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)

                        // Progress bar
                        SessionProgress(
                            context: context
                        )

                        // Status row
                        HStack {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(
                                        isPaused
                                            ? Ergo
                                                .orange
                                            : Ergo.green
                                    )
                                    .frame(
                                        width: 5,
                                        height: 5
                                    )
                                Text(
                                    isPaused
                                        ? "Paused"
                                        : "In Progress"
                                )
                                .font(.caption2)
                                .foregroundColor(
                                    isPaused
                                        ? Ergo.orange
                                        : Ergo.green
                                )
                            }
                            Spacer()
                            Text(
                                "Target \(formatTime(target))"
                            )
                            .font(.caption2)
                            .foregroundColor(
                                Ergo.textSub
                            )
                        }
                    }
                }
            } compactLeading: {
                // Compact pill: icon on the left
                Image(
                    systemName: isPaused
                        ? "pause.fill"
                        : "figure.run"
                )
                .font(
                    .system(size: 14, weight: .semibold)
                )
                .foregroundColor(
                    isPaused ? Ergo.orange : Ergo.blue
                )
            } compactTrailing: {
                // Compact pill: timer on the right
                SessionTimer(
                    context: context, size: .compact
                )
            } minimal: {
                // Minimal: just the icon
                Image(
                    systemName: isPaused
                        ? "pause.fill"
                        : "figure.run"
                )
                .font(
                    .system(size: 12, weight: .semibold)
                )
                .foregroundColor(
                    isPaused ? Ergo.orange : Ergo.blue
                )
            }
        }
    }
}

// MARK: - Lock Screen Banner

@available(iOSApplicationExtension 16.1, *)
struct LockScreenView: View {
    let context: ActivityViewContext<
        LiveActivitiesAppAttributes
    >

    var body: some View {
        let attrs = context.attributes
        let taskName = sharedDefault.string(
            forKey: attrs.prefixedKey("taskName")
        ) ?? "Session"
        let targetSec = sharedDefault.integer(
            forKey: attrs.prefixedKey("targetSeconds")
        )
        let isPaused = sharedDefault.bool(
            forKey: attrs.prefixedKey("isPaused")
        )

        HStack(spacing: 14) {
            // Left: icon badge
            ZStack {
                Circle()
                    .fill(
                        (isPaused
                            ? Ergo.orange : Ergo.blue
                        ).opacity(0.2)
                    )
                    .frame(width: 40, height: 40)
                Image(systemName: "figure.run")
                    .font(
                        .system(
                            size: 16, weight: .bold
                        )
                    )
                    .foregroundColor(
                        isPaused
                            ? Ergo.orange : Ergo.blue
                    )
            }

            // Center: name + progress
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(taskName)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    Spacer()
                    StatusBadge(isPaused: isPaused)
                }
                SessionProgress(context: context)
            }

            // Right: timer + target
            VStack(alignment: .trailing, spacing: 2) {
                SessionTimer(
                    context: context,
                    size: .lockscreen
                )
                Text(formatTime(targetSec))
                    .font(
                        .system(
                            size: 11,
                            weight: .medium,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(Ergo.textSub)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .activityBackgroundTint(Ergo.bgDark)
        .activitySystemActionForegroundColor(.white)
    }
}

// MARK: - Status Badge

private struct StatusBadge: View {
    let isPaused: Bool

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(
                    isPaused ? Ergo.orange : Ergo.green
                )
                .frame(width: 5, height: 5)
            Text(isPaused ? "Paused" : "Active")
                .font(
                    .system(
                        size: 9, weight: .semibold
                    )
                )
                .foregroundColor(
                    isPaused
                        ? Ergo.orange : Ergo.green
                )
        }
    }
}

// MARK: - Session Timer

enum TimerSize {
    case compact, medium, lockscreen
}

@available(iOSApplicationExtension 16.1, *)
struct SessionTimer: View {
    let context: ActivityViewContext<
        LiveActivitiesAppAttributes
    >
    let size: TimerSize

    private var fontSize: CGFloat {
        switch size {
        case .compact: return 11
        case .medium: return 16
        case .lockscreen: return 18
        }
    }

    var body: some View {
        let attrs = context.attributes
        let isPaused = sharedDefault.bool(
            forKey: attrs.prefixedKey("isPaused")
        )

        if isPaused {
            let elapsed = sharedDefault.integer(
                forKey: attrs.prefixedKey(
                    "elapsedSeconds"
                )
            )
            Text(formatTime(elapsed))
                .font(
                    .system(
                        size: fontSize,
                        weight: .bold,
                        design: .monospaced
                    )
                )
                .foregroundColor(Ergo.orange)
        } else {
            let startMs = sharedDefault.double(
                forKey: attrs.prefixedKey("startedAtMs")
            )
            if startMs > 0 {
                let startDate = Date(
                    timeIntervalSince1970:
                        startMs / 1000.0
                )
                Text(startDate, style: .timer)
                    .font(
                        .system(
                            size: fontSize,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(Ergo.green)
                    .monospacedDigit()
            } else {
                Text("00:00")
                    .font(
                        .system(
                            size: fontSize,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(Ergo.green)
            }
        }
    }
}

// MARK: - Session Progress Bar

@available(iOSApplicationExtension 16.1, *)
struct SessionProgress: View {
    let context: ActivityViewContext<
        LiveActivitiesAppAttributes
    >

    var body: some View {
        let attrs = context.attributes
        let elapsed = sharedDefault.integer(
            forKey: attrs.prefixedKey("elapsedSeconds")
        )
        let target = sharedDefault.integer(
            forKey: attrs.prefixedKey("targetSeconds")
        )
        let isPaused = sharedDefault.bool(
            forKey: attrs.prefixedKey("isPaused")
        )
        let progress =
            target > 0
            ? min(
                Double(elapsed) / Double(target), 1.0
            )
            : 0

        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: isPaused
                                ? [
                                    Ergo.orange,
                                    Ergo.orange,
                                ]
                                : [
                                    Ergo.blue,
                                    Ergo.green,
                                ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(
                            geo.size.width
                                * progress, 0
                        ),
                        height: 4
                    )
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Helpers

private func formatTime(
    _ totalSeconds: Int
) -> String {
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    return String(
        format: "%02d:%02d", minutes, seconds
    )
}
