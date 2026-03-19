import Foundation
import Testing
@testable import OpenHoof

@Suite(.serialized) struct NodeServiceManagerTests {
    @Test func `builds node service commands with current CLI shape`() throws {
        let tmp = try makeTempDirForTests()
        CommandResolver.setProjectRoot(tmp.path)

        let openhoofPath = tmp.appendingPathComponent("node_modules/.bin/openhoof")
        try makeExecutableForTests(at: openhoofPath)

        let start = NodeServiceManager._testServiceCommand(["start"])
        #expect(start == [openhoofPath.path, "node", "start", "--json"])

        let stop = NodeServiceManager._testServiceCommand(["stop"])
        #expect(stop == [openhoofPath.path, "node", "stop", "--json"])
    }
}
