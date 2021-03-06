/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import WebKit

class PrivateBrowsingTests: KIFTestCase {
    private var webRoot: String!

    override func setUp() {
        webRoot = SimplePageServer.start()
    }

    override func tearDown() {
        do {
            try tester().tryFindingTappableViewWithAccessibilityLabel("home")
            tester().tapViewWithAccessibilityLabel("home")
        } catch _ {
        }
        BrowserUtils.resetToAboutHome(tester())
    }

    func testPrivateTabDoesntTrackHistory() {
        // First navigate to a normal tab and see that it tracks
        let url1 = "\(webRoot)/numberedPage.html?page=1"
        tester().tapViewWithAccessibilityIdentifier("url")
        tester().clearTextFromAndThenEnterTextIntoCurrentFirstResponder("\(url1)\n")
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")
        tester().waitForTimeInterval(3)

        tester().tapViewWithAccessibilityIdentifier("url")
        tester().tapViewWithAccessibilityLabel("History")

        var tableView = tester().waitForViewWithAccessibilityIdentifier("History List") as! UITableView
        XCTAssertEqual(tableView.numberOfRowsInSection(0), 1)
        tester().tapViewWithAccessibilityLabel("Cancel")

        // Then try doing the same thing for a private tab
        tester().tapViewWithAccessibilityLabel("Show Tabs")
        tester().tapViewWithAccessibilityLabel("Private Mode")
        tester().tapViewWithAccessibilityLabel("Add Tab")
        tester().tapViewWithAccessibilityIdentifier("url")

        tester().clearTextFromAndThenEnterTextIntoCurrentFirstResponder("\(url1)\n")
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")

        tester().tapViewWithAccessibilityIdentifier("url")
        tester().tapViewWithAccessibilityLabel("History")

        tableView = tester().waitForViewWithAccessibilityIdentifier("History List") as! UITableView
        XCTAssertEqual(tableView.numberOfRowsInSection(0), 1)

        // Exit private mode
        tester().tapViewWithAccessibilityLabel("Cancel")
        tester().tapViewWithAccessibilityLabel("Show Tabs")
        tester().tapViewWithAccessibilityLabel("Private Mode")
        tester().tapViewWithAccessibilityLabel("Page 1")
    }

    func testTabCountShowsOnlyNormalOrPrivateTabCount() {
        let url1 = "\(webRoot)/numberedPage.html?page=1"
        tester().tapViewWithAccessibilityIdentifier("url")
        tester().clearTextFromAndThenEnterTextIntoCurrentFirstResponder("\(url1)\n")
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")

        // Add two tabs and make sure we see the right tab count
        tester().tapViewWithAccessibilityLabel("Show Tabs")
        tester().tapViewWithAccessibilityLabel("Add Tab")
        var tabButton = tester().waitForViewWithAccessibilityLabel("Show Tabs") as! UIButton
        XCTAssertEqual(tabButton.titleLabel?.text, "2", "Tab count shows 2 tabs")

        // Add a private tab and make sure we only see the private tab in the count, and not the normal tabs
        tester().tapViewWithAccessibilityLabel("Show Tabs")
        tester().tapViewWithAccessibilityLabel("Private Mode")
        tester().tapViewWithAccessibilityLabel("Add Tab")

        tabButton = tester().waitForViewWithAccessibilityLabel("Show Tabs") as! UIButton
        XCTAssertEqual(tabButton.titleLabel?.text, "1", "Private tab count should show 1 tab opened")

        // Switch back to normal tabs and make sure the private tab doesnt get added to the count
        tester().tapViewWithAccessibilityLabel("Show Tabs")
        tester().tapViewWithAccessibilityLabel("Private Mode")
        tester().tapViewWithAccessibilityLabel("Page 1")

        tabButton = tester().waitForViewWithAccessibilityLabel("Show Tabs") as! UIButton
        XCTAssertEqual(tabButton.titleLabel?.text, "2", "Tab count shows 2 tabs")
    }

    func testNoPrivateTabsShowsAndHidesEmptyView() {
        // Do we show the empty private tabs panel view?
        tester().tapViewWithAccessibilityLabel("Show Tabs")
        tester().tapViewWithAccessibilityLabel("Private Mode")
        XCTAssertTrue(tester().viewExistsWithLabel("Private Browsing"))

        // Do we hide it when we add a tab?
        tester().tapViewWithAccessibilityLabel("Add Tab")
        tester().waitForViewWithAccessibilityLabel("Show Tabs")
        tester().tapViewWithAccessibilityLabel("Show Tabs")

        XCTAssertFalse(tester().viewExistsWithLabel("Private Browsing"), "Private browsing title on empty view is hidden")

        // Remove the private tab - do we see the empty view now?
        let tabsView = tester().waitForViewWithAccessibilityLabel("Tabs Tray").subviews.first as! UICollectionView
        while tabsView.numberOfItemsInSection(0) > 0 {
            let cell = tabsView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))!
            tester().swipeViewWithAccessibilityLabel(cell.accessibilityLabel, inDirection: KIFSwipeDirection.Left)
            tester().waitForAbsenceOfViewWithAccessibilityLabel(cell.accessibilityLabel)
        }

        XCTAssertTrue(tester().viewExistsWithLabel("Private Browsing"), "Private browsing title on empty view is visible")

        // Exit private mode
        tester().tapViewWithAccessibilityLabel("Private Mode")
    }
}
