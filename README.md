[![](https://img.shields.io/badge/fluent-design-blue?style=flat-square&color=gray&labelColor=0078D7)](https://github.com/bdlukaa/fluent_ui) 

## WTbgA - War Thunder background Assistant

War Thunder's Windows assistant with many features and abilities!

### Installation

Installation of the application is pretty simple, just install the app using the already uploaded releases. Run the `installer.bat` and let the process of installing my certificate be done, then install the MSIX package.

This application uses VonAssistant, my private utility which handles updates, runs at startups, etc.

### Usage

After running WTbgA, you will see a Home page. If you see spinning loading indicators, this means the app is unable to receive info from War Thunder's local API. The game has to be running, no VPNs connected, and you must be on a plane.

The Home page displays essential information about your plane, e.g. IAS, climb rate, altitude, etc.

The Game Map section shows your plane and other objects on the game map. The Enemy Proximity alert only works when this page is open.

The Game Chat displays the ongoing chat in a match.

The Settings section allows you to modify application settings, you can toggle all notifications at once, make the app run at startup, run a semi-stable streaming server, or reset app data. You can also see the “Notifiers” category. These notifiers will get fired in different cases:

*   Engine dies
*   Engine, Oil, and Water overheat
*   Your plane is at a dangerous angle and speed, so you have to “Pull Up”.
*   High G overload.
*   Enemy proximity is a premium feature of the application and is set through Firebase by myself.

You may notice the OpenRGB icon at the top-right corner of the UI. This feature allows WTbgA to create lighting effects in different scenarios:

*   Catching fire
*   Losing your vehicle
*   Game loading/joining battle
*   Something overheats

Enabling this feature requires OpenRGB to be downloaded, set up, and enabled. You can enable OpenRGB integration to be enabled by default.

After setup and connection, you will see the OpenRGB Settings section is enabled. You can customize the effects and their colors on this page.

### Build the project

Requirements:

1.  Flutter SDK
2.  [Windows Setup](https://docs.flutter.dev/get-started/install/windows#windows-setup)

To build your fork of WTbgA, clone/fork this repository:

```plaintext
git clone https://github.com/Vonarian/wtbga.git
cd wtbga
```

Now you are in the project's directory, run the following command(s) to build this project for Windows:

```plaintext
flutter pub get
flutter build windows
```

Optionally, you can use [Puro](https://puro.dev). This allows developers to improve disk/internet usage.

**Note**: This application uses Firebase. Secret information for this service is not included in the repository, you need to either remove the dependencies or make your own configurations.

### War Thunder Forum

You can check out the application's forum page [here](https://forum.warthunder.com/index.php?/topic/533554-war-thunder-background-assistant-wtbga/).

## Contributions

Please head to the [Issues](https://github.com/Vonarian/wtbga/issues) section and file any bugs and improvements you have in mind :)
