//
//  BackgroundRepeatingTimer.swift
//  SwiftGraylog
//
//  Created by Alexandre Karst on 14/11/2018.
//  Copyright © 2018 iAdvize. All rights reserved.
//

import Foundation

typealias TimerEventHandler = (() -> Void)?

/// Source: https://gist.github.com/danielgalasko/1da90276f23ea24cb3467c33d2c05768#file-repeatingtimer-swift
/// RepeatingTimer mimics the API of DispatchSourceTimer but in a way that prevents
/// crashes that occur from calling resume multiple times on a timer that is
/// already resumed (noted by https://github.com/SiftScience/sift-ios/issues/52.
class BackgroundRepeatingTimer {
    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    let timeInterval: TimeInterval

    let firingQueue: DispatchQueue

    let timerEventHandler: TimerEventHandler

    init(timeInterval: TimeInterval, queue: DispatchQueue, timerEventHandler: TimerEventHandler) {
        self.timeInterval = timeInterval
        self.firingQueue = queue
        self.timerEventHandler = timerEventHandler
    }

    private lazy var timer: DispatchSourceTimer = {
        let backgroundTimer = DispatchSource.makeTimerSource(queue: firingQueue)
        backgroundTimer.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        backgroundTimer.setEventHandler(handler: { [weak self] in
            self?.timerEventHandler?()
        })
        return backgroundTimer
    }()

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
    }

    func resume() {
        guard state != .resumed else { return }

        state = .resumed
        timer.resume()
    }

    func suspend() {
        guard state != .suspended else { return }

        state = .suspended
        timer.suspend()
    }
}
