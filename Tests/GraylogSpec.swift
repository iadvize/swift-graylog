//
//  GraylogSpec.swift
//  Tests
//
//  Created by Alexandre Karst on 14/11/2018.
//  Copyright © 2018 iAdvize. All rights reserved.
//

import Foundation
import Nimble
import Quick
import Mockingjay

@testable import SwiftGraylog

class GraylogSpec: QuickSpec {
    lazy var logger: Graylog = {
        let graylog = Graylog()
        graylog.graylogURL = URL(string: "https://yourgraylog.com/gelf")!

        return graylog
    }()

    func buildLog(message: String) -> LogElement {
        return LogElement(values: ["message": message])
    }

    // swiftlint:disable:next function_body_length
    override func spec() {
        beforeEach {
            // By default we stub the Graylog call to a successfull one.
            self.stub(uri("/gelf"), http(202))
            self.logger.pendingLogsBatch = []
            self.logger.userDefaults.set([], forKey: Graylog.userDefaultsKey)
        }

        // MARK: - save(log:)/save(logs:)
        describe("save(log:): save a LogElement in the userDefaults") {
            // MARK: - when there is no pending logs
            context("when there is no pending logs") {
                it("should properly add this first log to the list of pending logs") {
                    let log = self.buildLog(message: "First Log Ever")

                    expect(self.logger.pendingLogs()).to(beEmpty())

                    self.logger.save(log: log)

                    let pendingLogs = self.logger.pendingLogs()

                    expect(pendingLogs?.count).to(equal(1))
                    expect(pendingLogs?[0].values["message"] as? String).to(equal("First Log Ever"))
                }
            }

            // MARK: - when there were pending logs but they were all sent
            context("when there were pending logs but they were all sent") {
                it("should return an empty array as the pending logs list") {
                    expect(self.logger.pendingLogs()?.isEmpty).to(beTrue())
                }
            }

            // MARK: - when there are pending logs and we add one
            context("when there are pending logs and we add one") {
                it("should properly add this log at this end of the list of pending logs") {
                    (0...2).forEach { index in
                        let log = self.buildLog(message: "Log \(index)")
                        self.logger.save(log: log)
                    }

                    expect(self.logger.pendingLogs()?.count).to(equal(3))

                    let log = self.buildLog(message: "New Log")
                    self.logger.save(log: log)

                    expect(self.logger.pendingLogs()?.count).to(equal(4))

                    let pendingLogs = self.logger.pendingLogs()
                    expect(pendingLogs?[3].values["message"] as? String).to(equal("New Log"))
                }
            }

            // MARK: - when the pending logs list is full and we try to add more logs
            context("when the pending logs list is full and we try to add more logs") {
                it("should not add these additional logs") {
                    var logs: [LogElement] = []
                    (0...Graylog.maximumLogsCount-1).forEach { index in
                        let log = self.buildLog(message: "Log \(index)")
                        logs.append(log)
                    }

                    self.logger.save(logs: logs)

                    expect(self.logger.pendingLogs()?.count).to(equal(Graylog.maximumLogsCount))

                    let log = self.buildLog(message: "New Log")
                    self.logger.save(log: log)

                    expect(self.logger.pendingLogs()?.count).to(equal(Graylog.maximumLogsCount))

                    let pendingLogs = self.logger.pendingLogs()
                    expect(pendingLogs?[Graylog.maximumLogsCount-1].values["message"] as? String).toNot(equal("New Log"))
                }
            }
        }

        // MARK: - insert(logs:)
        describe("insert(logs:): insert logs at a specific position of an array (.begin/.end)") {
            // MARK: - when we insert a log at the beginning of the array
            context("when we insert a log at the beginning of the array") {
                it("should properly put it on top of the pending logs list") {
                    (0...2).forEach { index in
                        let log = self.buildLog(message: "Log \(index)")
                        self.logger.save(log: log)
                    }

                    let log = self.buildLog(message: "Log at beginning")

                    self.logger.insert(logs: [log], at: .begin)

                    let pendingLogs = self.logger.pendingLogs()
                    expect(pendingLogs?[0].values["message"] as? String).to(equal("Log at beginning"))
                }
            }

            // MARK: - when we insert a log at the end of the array
            context("when we insert a log at the end of the array") {
                it("should properly put it at the end of the pending logs list") {
                    (0...2).forEach { index in
                        let log = self.buildLog(message: "Log \(index)")
                        self.logger.save(log: log)
                    }

                    let log = self.buildLog(message: "Log at end")

                    self.logger.insert(logs: [log], at: .end)

                    let pendingLogs = self.logger.pendingLogs()
                    expect(pendingLogs?[3].values["message"] as? String).to(equal("Log at end"))
                }
            }
        }

        // MARK: - prepareLogsBatch(logs:)
        describe("prepareLogsBatch(): will dequeue X logs from the pending logs list") {
            // MARK: - when there is no pending logs
            context("when there is no pending logs") {
                it("should not update the `pendingLogsBatch` array") {
                    expect(self.logger.pendingLogsBatch).to(beEmpty())

                    self.logger.prepareLogsBatch()

                    expect(self.logger.pendingLogsBatch).to(beEmpty())
                }
            }

            // MARK: - when there are pending logs (less than the batch count)
            context("when there are pending logs (less than the batch count)") {
                it("should move all remaining logs from the pending logs to the `pendingLogsBatch` array") {
                    expect(self.logger.pendingLogsBatch).to(beEmpty())
                    expect(self.logger.pendingLogs()).to(beEmpty())

                    (0...2).forEach { index in
                        let log = self.buildLog(message: "Log \(index)")
                        self.logger.save(log: log)
                    }

                    expect(self.logger.pendingLogs()?.count).to(equal(3))
                    expect(self.logger.pendingLogsBatch).to(beEmpty())

                    self.logger.prepareLogsBatch()

                    expect(self.logger.pendingLogs()?.count).to(equal(0))
                    expect(self.logger.pendingLogsBatch.count).to(equal(3))

                    (0...2).forEach { index in
                        expect(self.logger.pendingLogsBatch[index].values["message"] as? String).to(equal("Log \(index)"))
                    }
                }
            }

            // MARK: - when there are pending logs (more than the batch count)
            context("when there are pending logs (more than the batch count)") {
                it("should move X remaining logs from the pending logs to the `pendingLogsBatch` array") {
                    expect(self.logger.pendingLogsBatch).to(beEmpty())
                    expect(self.logger.pendingLogs()).to(beEmpty())

                    (0...15).forEach { index in
                        let log = self.buildLog(message: "Log \(index)")
                        self.logger.save(log: log)
                    }

                    expect(self.logger.pendingLogs()?.count).to(equal(16))
                    expect(self.logger.pendingLogsBatch).to(beEmpty())

                    self.logger.prepareLogsBatch()

                    expect(self.logger.pendingLogs()?.count).to(equal(16 - Graylog.batchCount))
                    expect(self.logger.pendingLogsBatch.count).to(equal(Graylog.batchCount))

                    (0...Graylog.batchCount-1).forEach { index in
                        expect(self.logger.pendingLogsBatch[index].values["message"] as? String).to(equal("Log \(index)"))
                    }
                }
            }
        }

        // MARK: - completeLog(log:)
        describe("completeLog(log:): will remove the log from the `pendingLogsBatch` array") {
            // MARK: - when we complete a log which is in the `pendingLogsBatch` array
            context("when we complete a log which is in the `pendingLogsBatch` array") {
                it("should properly remove it from the `pendingLogsBatch` array") {
                    expect(self.logger.pendingLogsBatch).to(beEmpty())

                    (0...2).forEach { index in
                        let log = self.buildLog(message: "Log \(index)")
                        self.logger.save(log: log)
                    }

                    self.logger.prepareLogsBatch()

                    expect(self.logger.pendingLogsBatch.count).to(equal(3))

                    self.logger.completeLog(log: self.logger.pendingLogsBatch[0])

                    expect(self.logger.pendingLogsBatch.count).to(equal(2))

                    expect(self.logger.pendingLogsBatch[0].values["message"] as? String).to(equal("Log 1"))
                    expect(self.logger.pendingLogsBatch[1].values["message"] as? String).to(equal("Log 2"))
                }
            }
        }

        // MARK: - send(log)
        describe("send(log): send a log to the Graylog server (stubbed here)") {
            // MARK: - when we fail to send the log
            context("when we fail to send the log") {
                it("should save the log in the pending logs list") {
                    // We stub an issue in the HTTP call to force saving the log.
                    // In this case no logs should be saved because the Graylog should
                    // ignore all logs with a level different from .warning and .error.
                    self.stub(uri("/gelf"), http(404))

                    let errorLog = self.buildLog(message: "Log error")

                    self.logger.log(errorLog)

                    expect(self.logger.pendingLogs()?.count).toEventually(equal(1), timeout: 1, pollInterval: 1)
                }
            }

            // MARK: - when we succeed to send the log
            context("when we succeed to send the log") {
                it("should not save the log in the pending logs list") {
                    let errorLog = self.buildLog(message: "Log error")

                    self.logger.log(errorLog)

                    expect(self.logger.pendingLogs()).toEventually(beEmpty(), timeout: 5, pollInterval: 1)
                }
            }
        }

        // MARK: - sendPendingLogs()
        describe("sendPendingLogs(): send pending logs to the Graylog server (stubbed here)") {
            // MARK: - when we don't have any pending logs
            context("when we don't have any pending logs") {
                it("should not do anything") {
                    self.logger.userDefaults.set([], forKey: Graylog.userDefaultsKey)
                    expect(self.logger.pendingLogs()?.count).to(equal(0))

                    self.logger.sendPendingLogs()

                    expect(self.logger.pendingLogs()).toEventually(beEmpty(), timeout: 1, pollInterval: 1)
                    expect(self.logger.pendingLogsBatch).toEventually(beEmpty(), timeout: 1, pollInterval: 1)
                }
            }

            // MARK: - when we have pending logs and we fail to send them
            context("when we have pending logs and we fail to send them") {
                it("should save the logs in the pending logs list") {
                    // We stub an issue in the HTTP call to force saving the log.
                    // In this case no logs should be saved because the Graylog should
                    // ignore all logs with a level different from .warning and .error.
                    self.stub(uri("/gelf"), http(404))

                    var logs: [LogElement] = []

                    (0...15).forEach { index in
                        let log = self.buildLog(message: "Log \(index)")
                        logs.append(log)
                    }

                    self.logger.save(logs: logs)

                    expect(self.logger.pendingLogs()?.count).to(equal(16))
                    expect(self.logger.pendingLogsBatch.count).to(equal(0))

                    self.logger.sendPendingLogs()

                    expect(self.logger.pendingLogsBatch.count).to(equal(10))

                    expect(self.logger.pendingLogs()?.count).toEventually(equal(16), timeout: 1, pollInterval: 1)
                    expect(self.logger.pendingLogsBatch.count).toEventually(equal(0), timeout: 1, pollInterval: 1)
                }
            }

            // MARK: - when we have pending logs and we succeed to send them
            context("when we have pending logs and we succeed to send them") {
                it("should remove the completed logs from the pending logs list") {
                    var logs: [LogElement] = []

                    (0...15).forEach { index in
                        let log = self.buildLog(message: "Log \(index)")
                        logs.append(log)
                    }

                    self.logger.save(logs: logs)

                    expect(self.logger.pendingLogs()?.count).to(equal(16))
                    expect(self.logger.pendingLogsBatch.count).to(equal(0))

                    self.logger.sendPendingLogs()

                    expect(self.logger.pendingLogs()?.count).toEventually(equal(6), timeout: 1, pollInterval: 1)
                    expect(self.logger.pendingLogsBatch.count).toEventually(equal(0), timeout: 1, pollInterval: 1)
                }
            }
        }
    }
}
