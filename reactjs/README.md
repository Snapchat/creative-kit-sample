<!-- @format -->

# Creative Kit x React Native

Creative Kit sample code for React Native.

## Prerequisite

There is no special setup required to use Creative Kit Web (other than including the share button on your site).

## App Registration

1. Go to the [Snap Kit developer portal](https://kit.snapchat.com/portal/) > Sign-in with your Snapchat Account > Either create a new App by clicking on **New Project** Or Open an already existing app.
<p>

2. After the app is registered, click **Setup** and you should see two OAuth Client IDs:

   | OAuth Client ID | Usage                                                                                                                                                                             |
   | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
   | Production      | This lets your app post content from any Snapchat account but your app [must be approved](https://docs.snapchat.com/docs/review-guidelines) for the Production Client ID to work. |
   | Staging         | This lets your app post content even before an app is reviewed and approved but only Snapchat accounts listed under the `Demo Users` will be able to use your application.        |

## Running the Sample App

1. Clone the Sample App repository on your local machine

   ```shell
   # Clone the repo
   $ git clone https://github.com/Snapchat/creative-kit-sample.git

   # CD into the React root directory
   $ cd creative-kit-sample/reactjs/
   ```

   **Note:** You should now be inside the **react-native root directory**: `/Users/.../creative-kit-sample/react-native/`

<p>

2. Run the `ReactCreativeKitDemo` app

   ```shell
   # Running on localhost
   $ yarn dev
   ```
