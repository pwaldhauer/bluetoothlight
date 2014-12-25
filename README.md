# BluetoothLight

iOS app to remote control a custom, [Espruino](http://www.espruino.com/) powered strip of LEDs.

Just hacked together in some hours, might not work for you at all!

![Screenshot](https://s3-eu-west-1.amazonaws.com/knusperfiles/bluelight.gif)

German: [Die exklusive Hintergrundgeschichte](http://knuspermagier.de/2014-lichterkette.html) im Blog!

# Prerequisites

- 1x [Espruino](http://www.espruino.com/)
- 1x HM-10 Bluetooth module ([Wiring up](http://www.espruino.com/Bluetooth+BLE))
- 1x WS2811 LED strip ([Wiring up](http://www.espruino.com/WS2811))

# Running it

- Wire everything up and push the `code.js` to your Espruino
- Launch the app
- Everything should work!

# Troubleshooting

After making sure everything is wired up correctly use some test app (like [LightBlue](https://itunes.apple.com/de/app/lightblue-bluetooth-low-energy/id557428110?mt=8)) to see if the Bluetooth is working correctly and the device is discoverable. Also maybe your peripheral name may not be "HM-10" and needs to be changed in the apps source code.

# Licence

MIT
