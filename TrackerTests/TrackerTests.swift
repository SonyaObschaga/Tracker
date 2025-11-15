import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackerViewControllerLightTheme() {
        // Given
        let vc = TrackerViewController()
        
        // When
        vc.loadViewIfNeeded()
        
        // Then
        assertSnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            named: "LightTheme"
        )
    }
    
    func testTrackerViewControllerDarkTheme() {
        // Given
        let vc = TrackerViewController()
        
        // When
        vc.loadViewIfNeeded()
        
        // Then
        assertSnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "DarkTheme"
        )
    }
}
