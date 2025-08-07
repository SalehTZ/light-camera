# Light Camera

A simple Flutter application for recording, previewing, and saving videos to the gallery.

## Features

* **Record Video:** Easily record videos using the device's camera.
* **Preview Video:** Preview the recorded video before saving.
* **Save to Gallery:** Save the recorded video to the device's gallery.
* **Retake Video:** Option to discard the recorded video and retake a new one.

## Dependencies

This project uses the following main dependencies:

* [camera](https://pub.dev/packages/camera): For accessing the device's camera.
* [video_player](https://pub.dev/packages/video_player): For playing back the recorded video.
* [path_provider](https://pub.dev/packages/path_provider): To find the correct paths for storing the video file.
* [gal](https://pub.dev/packages/gal): To save the video to the device's gallery.

## Getting Started

1. **Clone the repository:**

    ```bash
    git clone https://github.com/Saleh-Talebi/light-camera.git
    ```

2. **Install dependencies:**

    ```bash
    flutter pub get
    ```

3. **Run the app:**

    ```bash
    flutter run
    ```

## Usage

1. Tap the video camera icon to start recording.
2. Tap the stop icon to stop recording.
3. The recorded video will be previewed automatically.
4. Tap the save icon to save the video to the gallery.
5. Tap the camera icon to retake the video.
