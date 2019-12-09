//
//  Graylog.swift
//  SwiftGraylog
//
//  Created by Alexandre Karst on 14/11/2018.
//  Copyright © 2018 iAdvize. All rights reserved.
//

import Foundation

/// Logger in charge of sending logs to Graylog.
/// If a log upload fails it will store pending logs locally (in the user defaults).
/// Will retry X seconds to re-upload failed logs.
///
/// Threading schema of log upload retry:
///
///                                   TICK
///                                     +
///                                     |
///                                     |                                                                      All logs uploaded
///           TimerSerialQueue+---------v----+--------------------------------------------------------------------------^-----------+------------------>
///                                          |                                                                          |           |
///                                          |                                                                          |           |
///                                          |                                                                          |           |
///                                          |                                                sendLog()  (...)+-------> |           |
/// URLSessionDataTaskQueueReq+--------------------------------------------------------------^-----------+--------------+------------------------------>
///                                          |                                               |(X TIMES)  |                          |
///                                          |                                               |           |                          |
///                                          |                                               |           |                          |
///                                          |  sendPendingLogs()+----> prepareLogsBatch()   |           |completeLog()             |updatePendingLogs()
///   logsReadWriteSerialQueue+--------------v-----------------------------------------------+-----------v--------------------------v------------------>
///
public class Graylog {
    // MARK: - Statics

    static let shared = Graylog()

    /// Key in front of which we save logs in the User Defaults.
    static let userDefaultsKey = "graylog.logs"

    /// Number of logs we try to send at each timer tick.
    static var batchCount = 10

    /// Time (in seconds) within the `sendsLogTimer` will fire to try to upload pending logs.
    static let timeInterval: TimeInterval = 60

    /// Prefix of GCD queues labels.
    static let queuePrefix = "graylog.queue"

    /// Maximum number of logs we store in the User Defaults.
    static let maximumLogsCount = 1000

    // We truncate logs to 250 characters max (to avoid full html pages in case of server issues)
    let logMessageMaxLength = 250

    // MARK: - Vars

    var graylogURL: URL?

    /// Timer which will fire after each `timeInterval` on a specific thread.
    var sendLogsTimer: BackgroundRepeatingTimer?

    /// Batch of logs that we will try to send each time the timer fires (`timeInterval`).
    var pendingLogsBatch: [LogElement] = []

    /// User Defaults instance used to save pending logs.
    var userDefaults: UserDefaults {
        return UserDefaults.standard
    }

    // MARK: - Queues

    /// A serial queue used to synchronise all read/write operations on pending logs.
    /// We synchronise each operations on the same serial queue to be sure we don't
    /// loose some logs by reading or writing concurrently the pending logs from different
    /// threads.
    let logsReadWriteSerialQueue = DispatchQueue(label: "\(Graylog.queuePrefix).logs.readwrite")

    /// A serial queue into which the timer will live and fire.
    let timerSerialQueue = DispatchQueue(label: "\(Graylog.queuePrefix).timer")

    // MARK: - init

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)

        sendLogsTimer = BackgroundRepeatingTimer(timeInterval: Graylog.timeInterval, queue: timerSerialQueue) { [weak self] in
            // Send pending logs synchronising logs
            // read/write operations.
            self?.logsReadWriteSerialQueue.sync {
                self?.sendPendingLogs()
            }
        }

        sendLogsTimer?.resume()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Logs operations

    func log(_ log: LogElement) {
        send(log: log)
    }

    /// Append and save a Log into the pending logs list.
    ///
    /// - Parameter log: Log information wrapped in a LogElement.
    func save(log: LogElement) {
        self.logsReadWriteSerialQueue.sync {
            insert(logs: [log], at: .end)
        }
    }

    /// Append and save a new list of logs at the desired position into the pending logs list.
    ///
    /// - Parameters:
    ///   - logs: Logs to save.
    ///   - position: Desired position in the pending logs list.
    func insert(logs: [LogElement], at position: ArrayPosition) {
        var resultLogs = pendingLogs() ?? []

        guard resultLogs.count + logs.count < Graylog.maximumLogsCount else {
            return
        }

        resultLogs.queue(logs, at: position)

        save(logs: resultLogs)
    }

    /// Replace the saved pending logs list by the list in parameter.
    ///
    /// - Parameters:
    ///   - logs: New logs list.
    func save(logs: [LogElement]) {
        let values = logs.map { return $0.values }
        userDefaults.set(values, forKey: Graylog.userDefaultsKey)
    }

    /// Retrieve the actual list of the pending logs.
    ///
    /// - Returns: All pending logs list.
    func pendingLogs() -> [LogElement]? {
        guard let values = userDefaults.array(forKey: Graylog.userDefaultsKey) as? [LogValues] else {
            return nil
        }

        return values.map(LogElement.init)
    }

    // MARK: - Logs sending

    /// Each log which came through the logger should be sent to the Graylog server.
    ///
    /// - Parameter log: Log information to send to the server.
    private func send(log: LogElement) {
        postLogRequest(log: log) { success in
            guard success else {
                self.save(log: log)
                return
            }
        }
    }

    /// As Graylog API doesn't support batch mode for logs sending, we will prepare batches
    /// of X pending logs (logs which we failed to send) and send them one by one to Graylog.
    func prepareLogsBatch() {
        guard var logs = pendingLogs(),
            logs.count > 0 else {
                return
        }

        pendingLogsBatch = logs.dequeueFirst(Graylog.batchCount)

        save(logs: logs)
    }

    /// Called this method when a pending log was successfully sent to the server.
    ///
    /// - Parameter log: Log successfully sent.
    func completeLog(log: LogElement) {
        self.logsReadWriteSerialQueue.sync {
            if let index = self.pendingLogsBatch.firstIndex(of: log) {
                self.pendingLogsBatch.remove(at: index)
            }
        }
    }

    /// Send the pending logs (logs which we fail to send).
    @objc func sendPendingLogs() {
        prepareLogsBatch()

        guard pendingLogsBatch.count > 0 else {
            return
        }

        let group = DispatchGroup()

        pendingLogsBatch.forEach { log in
            group.enter()
            postLogRequest(log: log) { success in
                if success {
                    // In case of success, we can remove the log from pendingLogsBatch.
                    // Otherwise we let it in the pending logs list.
                    self.completeLog(log: log)
                }

                group.leave()
            }
        }

        group.notify(queue: timerSerialQueue) {
            // If some logs failed, we requeue them.
            self.logsReadWriteSerialQueue.sync {
                if self.pendingLogsBatch.count > 0 {
                    self.insert(logs: self.pendingLogsBatch, at: .begin)
                    self.pendingLogsBatch = []
                }
            }
        }
    }

    /// Http request to send the log on the Graylog server.
    ///
    /// - Parameters:
    ///   - log: Log information to send to the server.
    ///   - completion: Called when the HTTP request is done or if it fails.
    private func postLogRequest(log: LogElement, completion: @escaping (_ success: Bool) -> Void) {
        do {
            guard let graylogURL = graylogURL else {
                print("Error! We are unable to send log to Graylog. No graylogURL set.")
                completion(false)
                return
            }

            let method: HTTPMethod = .post

            var urlRequest = try URLRequest(url: graylogURL, method: method)

            let body = try JSONSerialization.data(withJSONObject: log.values, options: .prettyPrinted)

            urlRequest.httpBody = body

            URLSession.shared.dataTask(with: urlRequest) {data, response, error in
                do {
                    try Networking.validate(data, response, error)
                    completion(true)
                } catch {
                    print("Error! We are unable to send log to Graylog: \(error.localizedDescription)")
                    completion(false)
                }
                }.resume()
        } catch {
            completion(false)
        }
    }
}

// MARK: - Application state observers

extension Graylog {
    @objc func applicationDidBecomeActive() {
        sendLogsTimer?.resume()
    }

    @objc func applicationWillResignActive() {
        sendLogsTimer?.suspend()
    }
}

extension Graylog {
    /// Set Graylog server API (`gelf`) URL.
    ///
    /// - Parameter url: Graylog server `gelf` URL.
    public static func setURL(_ url: URL) {
        Graylog.shared.graylogURL = url
    }

    /// Sends a log to Graylog. If it fails, we queue it and we retry the queued logs each minute.
    ///
    /// - Parameter values: JSON dictionary to be sent to Graylog. See http://docs.graylog.org/en/2.4/pages/gelf.html for available fields.
    public static func log(_ values: LogValues) {
        assert(Graylog.shared.graylogURL != nil)

        Graylog.shared.log(LogElement(values: values))
    }
}
