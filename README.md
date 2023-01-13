# Pongsense

Pongsense is a simple implementation of Pong with flutter (for android). But with a twist, the player paddle is controlled with the [ESense Earable][esense].

As the player tilts to the left and right, the paddle follows. This gives an interactive and dynamic way to play an old classic.

## Usage

To play the game with the best experience, follow these steps.

1. Open the app and enable Bluetooth
2. Start your [ESense Earable][esense]
3. While on the `Connect`-Tab, click on `Connect`
4. Wait until all connection state items have a checkmark
5. Go on the `Calibrate`-Tab
6. Tilt your head to the far left an click `Calibrate Left`
7. Tilt your head to the far right an click `Calibrate Right`
8. Now all calibrate state items should have a checkmark
9. Go on the `Play`-Tab
10. You can now move the (blue) player paddle by tilting your head from left to right
11. Try to get a high score before loosing all your lives (displayed on the top left, over the current score)
12. Have fun :smile:

## Features

Every feature of the app has a person responsible for it. This person created most or all of it.

<table>
  <thead>
    <tr>
      <th>Feature</th>
      <th>Paul</th>
      <th>Rico</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Tab routing with bottom navigation bar</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>Communicate global-state to widget-state with event-callbacks</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>Custom Flutter Esense Fork</td>
      <td>:heavy_check_mark:</td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>Connect Tab</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>Calibrate Tab</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>3D representation of eareble accelerometer</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>Ingame components (player/ai/ball/blocker)</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>Responsive grid blocker generation</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>Improved collision detection for fast moving ingame components</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>Smart collision handling for ingame components</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>Ingame soundeffects and music integration</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>Ingame pause and endgame overlay</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>Ingame game reset handling</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>BLE connection state handling</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>Failsafe eareable initialization sequence</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>Unexpected disconnect handling</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>Calibration handling</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>Eareable config sensitive calculations (needs custom fork)</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>Eareable orientation calculation</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>Eareable event propagation for Flame components</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
  </tbody>
</table>

## Custom Flutter Esense Fork

We created a [custom fork][flutter-esense-fork] for the [flutter_esense package][flutter-esense].
To be able to convert the esense outputs in usable formats like `g` or `m/s^2`, you have to get the current device configuration. Specifically to convert the accelerometer output, you need the accelerometers sensitivity factor.
The problem is, that the original flutter package didn't map the ESense output to the provided event class ([see here](https://github.com/HydrofinLoewenherz/flutter-plugins/commit/b7d0e74f8717288b76bf748e3230e1341e67e552)). Additionally we added utilities to convert the config values into the sensitivity factors specified in the [ESense specification][esense-specification] ([see here](https://github.com/HydrofinLoewenherz/flutter-plugins/commit/c44c6a45ac12b4a7aefde0cef0c6251a03f52edc)).

## Authors

The project was created by [Rico Münch (uozjn)][rico-github] and [Paul Wagner (ujhtl)][paul-github].

## Sources

The **Audio Files** that are used in the project are imported from [Storybooks][storybooks].

The following **Libraries** are used in the project

- [flame][flame] (2D game engine)
- [flame_audio][flame-audio] (audio for flame)
- [esense_flutter (custom fork)][flutter-esense-fork] (esense connection)
- [permission_handler][permission-handler] (ask for permissions on android)
- [ditredi][ditredi] (3D visualization package)

See the dependencies in the `pubspec.yml` for more information.

[esense]: https://www.esense.io/ "ESense Homepage"
[esense-specification]: https://www.esense.io/share/eSense-BLE-Specification.pdf "ESense Specification"

[storybooks]: https://www.storyblocks.com/ "Storybooks Stock Media"

[flutter-esense]: https://pub.dev/packages/esense_flutter "Flutter Esense Package"
[flutter-esense-fork]: https://github.com/HydrofinLoewenherz/flutter-plugins/tree/master/packages/esense_flutter "Flutter Esense Package (Custom Fork)"
[flame]: https://pub.dev/packages/flame "Flame Package"
[flame-audio]: https://pub.dev/packages/flame_audio "Flame Audio Package"
[permission-handler]: https://pub.dev/packages/permission_handler "Permission Handler Package"
[permission-handler]: https://pub.dev/packages/permission_handler "Permission Handler Package"
[ditredi]: https://pub.dev/packages/ditredi "ditredi Package"

[paul-github]: https://github.com/HydrofinLoewenherz "ujhtl"
[rico-github]: https://github.com/cryeprecision "uozjn"
