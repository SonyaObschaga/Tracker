import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testOnboardingViewController() {
        // Given
        let vc = TrackerViewController()
        
        // When
        vc.loadViewIfNeeded()
        
        // Then
        assertSnapshot(of: vc, as: .image)
    }
}
