//
//  ErgoLiveActivityBundle.swift
//  ErgoLiveActivity
//
//  Created by Anh Tu on 9/2/26.
//

import WidgetKit
import SwiftUI

@main
struct ErgoLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        ErgoLiveActivity()
        if #available(iOS 16.1, *) {
            ErgoLiveActivityLiveActivity()
        }
    }
}
