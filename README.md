[![CircleCI](https://circleci.com/gh/iadvize/swift-graylog.svg?style=svg)](https://circleci.com/gh/iadvize/swift-graylog)

# SwiftGraylog

Graylog library written in Swift.

## Compatibility

|   Version    | Minimum iOS Version | Swift Version |
| :----------: | :-----------------: | :-----------: |
| 1.1.0, 1.1.1 |       iOS 8.0       |    Swift 5    |
|    1.0.0     |       iOS 8.0       |    Swift 4    |

## Documentation

First you have to define your Graylog server URL:

```swift
if let url = URL(string: "https://yourgraylog.com/gelf") {
    Graylog.setURL(url)
}
```

Then you can send log to Graylog using the `log` method by passing a dictionary which represents your JSON payload:

```swift
Graylog.log(["message": "Hello Graylog!"])
```

Here is a list of available fields in Graylog: [Graylog Documentation](http://docs.graylog.org/en/2.4/pages/gelf.html)

If an issue is thrown while sending a log, a message will be printed in the Xcode console. The framework stores logs locally in the user preferences and retry the failed one each 60 seconds.

## Installation

### Cocoapods

Add the dependency to your Podfile:

```
pod 'SwiftGraylog'
```

and use `import SwiftGraylog` where you want to use it.

## Contribute

Look at contribution guidelines here: [CONTRIBUTING.md](CONTRIBUTING.md)

Once you've forked the repository you should  `pod install` at the root of the repository and open the `SwiftGraylog.xcworkspace` workspace.

N.B. You have access to template files for Pull Requests and Issues opening:

- [ISSUE_TEMPLATE.md](ISSUE_TEMPLATE.md)
- [PULL_REQUEST_TEMPLATE.md](PULL_REQUEST_TEMPLATE.md)
