# Creative Kit

Creative Kit sample code for iOS.

## App Registration

You need to register your app at the [Snap Kit developer portal](https://snapkit.com) with the `bundleID` associated with your app.

App registration is an important part of the workflow. Creative Kit requires both the `bundleID` and a `clientID`. At runtime, Snapchat will verify that the content to be shared is redirected from a legitimate app.

Two OAuth2 `clientIDs` will be automatically generated when you register an app on the [Snap Kit developer portal](https://snapkit.com). You will receive a *Production* `clientID` and a *Development* `clientID`.

You can use the *Development* `clientID` anytime even before an app is approved. But the content can only be posted from a Snapchat account that is registered under the *Demo Users* in the app registration/profile page on [Snap Kit developer portal](https://snapkit.com).

With the *Production* `clientID`, your app can post the content from any Snapchat account. But your app must be approved for the *Production* `clientID` to work.

## Setup

1. (Optional)You can run bundler to install Cocoapods.

  ```bash
  $ bundle install
  ```

1. Install Snap Kit SDK via [Cocoapods](https://cocoapods.org/).

  ```bash
  $ pod install
  ```

1. Open the project in Xcode.

  ```bash
  $ open CreativeKitSample.xcworkspace
  ```

1. Open Info.plist and modify the following attributes:

   * `SCSDKClientId` - OAuth2 client ID you receive from registering your app
   * `LSApplicationQueriesSchemes` - Always set the value to `snapchat`

1. Save your project.
1. Build and run the app on an iPhone.

## License

Copyright (c) 2019, [License](LICENSE).

This project uses images to demonstrate the sharing of content between the sample app and Snapchat. See [Attribution](ATTRIBUTION.md) for details.
