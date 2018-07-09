# Introduction
Course Lab for Mobile Internet (Xinbing Wang)

Current version: `V0.1 Beta`

Android application for the first four labs:
  1. Lab "Introduction", basic Android activity
  1. Lab "WiFi Signal", wifi scan
  1. Lab "Android Pedometer", use pedometer to detect steps
  1. Lab "QR Code", a QR code encoder and decoder
  
Please check your [development environment](#env) before using this code.

The structure of this application is listed [below](#structure).

Don't forget to check some recommendations listed [below](#recommendation).

# <a name="env"></a> Development system
Android Studio 3.0.1

Android SDK API 27 (Android 8.1 Oreo)

# <a name="structure"></a> Application Structure
Overall, the application has 4 functionalities:
  1. [Welcome page](#welcomePage), which shows some information about application and implement the first Lab.
  1. [Wifi Tool](#wifiTool). Implement the second Lab.
  1. [Pedometer](#pedometer). Implement the third Lab.
  1. [QR Code Tool](#qrcode). Implement the fourth lab.

## <a name="welcomePage"></a> 1. Welcome page
Files that you may want to edit:
  - Activity: `MainActivity.java`
  - Custom view component: `WelcomeView.java`
  - Layout: `content_main.xml`
  
`MainActivity.java` setup the application mainpage, as well as the navigation drawer.

`WelcomeView.java` is a custom view which implements a draw board.
It is built from one of those reference codes in Lab one.

*WARNING: ***DO NOT*** change `MainActivity.java` unless you know what you're doing.*

### TODO:
  - [ ] Beautify welcome page.
  - [ ] (Minor) Add more features according to the reference code.
  
## <a name="wifiTool"></a> 2. Wifi Tool
Files that you may want to edit:
  - Activity: `WifiActivity.java`
  - Layout `content_wifi.xml'

`WifiActivity.java` implements the wifi scan module required by Lab 2.

Strangly my test phone (mi 4c) can not scan wifi successfully, so this part is not fully developed.

### TODO:
  - [ ] Debug and make the scan work.
  - [ ] Implement a module which write string to a local file. This is also required in [Pedometer tool](#pedometer).
  - [ ] (If time permits) Tackle the indoor location problem listed on the reference of Lab 2.
  
## <a name="pedometer"></a> 3. Pedometer 
Files that you may want to edit:
  - Activity: `PedometerActivity.java`
  - Layout `content_pedometer.xml'
  
`PedometerActivity.java` uses pedometer sensor to detect the acceleration of phone.

### TODO:
  - [ ] Implement a module which write string to a local file. This is also required in [Wifi tool](#wifiTool).
  - [ ] Propose, implement and test the step counting algorithm.
  - [ ] (Minor) Beautify the interface, e.g., draw the curve of acculeration on the page.

## <a name="qrcode"></a> 4. QR Code
Files that you may want to edit:
  - Activity for welcome page: `QRCodeActivity.java`
  - Activity for QR code decoder: `QRDecoder.java`
  - Activity for QR code encoder: `QREncoder.java`
  - Main layout: `content_qrcode.xml`
  - QR code decoder layout: `content_qrdecoder.xml`
  - QR code encoder layout: `content_qrencoder.xml`
 
 Decoder: Open camera and scan an existing QR code. Read its content.
 
 Encoder: User input a string. Turn it into a QR code.
 
`QRCodeActivity.java` let the user choose to **decode** or **encode**.

`QRDecoder.java` and `QREncoder.java` implement the decoder and encoder module.

### TODO:
  - [x] Add support to open link directly after decoding the QR code.
  - [ ] Fix issue: Wechat link cannot be opened directly by calling the browser.
  - [ ] Add support to pick QR code image from phone's gallery.
  - [ ] Add support to save the encoded QR code image to phone's gallery.
  
  
# <a name="recommendation"></a> Recommendation
  1. Please open a new branch, say 'dev' and push your code their.
  We may discuss and merge it into the master branch.
  1. Using a physical Android phone for testing is recommended.
  Connect to the computer via USB cable, and turn on USB Debugging option on your phone.
  1. Please upload the compiled APK to release section if possible.
  1. Setup all static values for dimensions in `dimens.xml`, and all static strings in `strings.xml`.
  1. For simplicity, using `android.support.constraint.ConstraintLayout` in layout is recommended. 
  Refer to [this page](https://developer.android.com/reference/android/support/constraint/ConstraintLayout.html).
  1. Please update this README file when you have new ideas (add more "TODO"s), or have finished a "TODO".
  
  
  
