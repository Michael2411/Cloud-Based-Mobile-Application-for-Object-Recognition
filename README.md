# Cloud-based Mobile Application for Object Recognition

The goal of this project is to build a cloud based mobile application to recognize objects in images or using live camera stream based on deep learning techniques and features extraction. Also to provide the user with audio annotation to describe the objects in the image and their number, the ability to search for more information about any of the detected objects simply by a long press on the desired object and because the application is cloud based all images uploaded by the user will be stored on the cloud and ready for the user to access them at any time. The application can be useful to search for information about unknown objects and to save storage because the previously uploaded images are all stored on the cloud and can be accessed easily. 

## Usage

### 1. Set up the environment 
#### 1.1 Installiation

```bash
$ git clone https://github.com/tony-amgad/Cloud-Based-Mobile-Application-for-Object-Recognition.git
$ cd Cloud-Based-Mobile-Application-for-Object-Recognition
$ pip install -r requirements.txt
```
#### 1.2 Install additional requirements

* Download & install Flutter. (https://docs.flutter.dev/get-started/install)
* Download and install Android Studio. (https://developer.android.com/studio)
* Download ngrok. (https://ngrok.com/download)

### 2. Run the server
 
```bash
$ python app.py
```

```bash
$ ngrok http 5000
```

### 3. Run the mobile application

#### 3.1 Set up your Android device

To prepare to run and test your Flutter app on an Android device,
you need an Android device running Android 4.1 (API level 16) or higher.

1. Enable Developer options and USB debugging on your device. Detailed instructions are available in the Android documentation.
2. Windows-only: Install the Google USB Driver.
3. Using a USB cable, plug your phone into your computer. If prompted on your device, authorize your computer to access your device.
4. In the terminal, run the flutter devices command to verify that Flutter recognizes your connected Android device. By default, Flutter uses the version of the Android SDK where your adb tool is based. If you want Flutter to use a different installation of the Android SDK, you must set the ANDROID_SDK_ROOT environment variable to that installation directory.

#### 3.2 Set up the Android emulator

To prepare to run and test your Flutter app on the Android emulator, follow these steps:

1. Enable VM acceleration on your machine.
2. Launch Android Studio, click the AVD Manager icon, and select Create Virtual Device…
* In older versions of Android Studio, you should instead launch Android Studio > Tools > Android > AVD Manager and select Create Virtual Device…. (The Android submenu is only present when inside an Android project.)
* If you do not have a project open, you can choose Configure > AVD Manager and select Create Virtual Device…
3. Choose a device definition and select Next.
4. Select one or more system images for the Android versions you want to emulate, and select Next. An x86 or x86_64 image is recommended.
5. Under Emulated Performance, select Hardware - GLES 2.0 to enable hardware acceleration.
6. Verify the AVD configuration is correct, and select Finish.
7. In Android Virtual Device Manager, click Run in the toolbar. The emulator starts up and displays the default canvas for your selected OS version and device.