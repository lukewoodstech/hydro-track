import WidgetKit
import SwiftUI

@main
struct HydroTrackWidgetBundle: WidgetBundle {
    var body: some Widget {
        HydroLockScreenWidget()
        HydroHomeScreenWidget()
    }
}
