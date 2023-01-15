# Pongsense

Pongsense is a simple implementation of the game Pong with flutter (for android). But with a twist, the player paddle is controlled with the [ESense Earable][esense].

As the player tilts his head to the left and right, the paddle follows. This gives an interactive and dynamic way to play an old classic.

## Considerations

- **Target domain**: Anyone who wants to replay an old classic while also getting some movement in
- **Application class**: Gamebox
- **Senses used**: Motory skills and vision (coordination between head position and eyes)
- **Addressed part of memory**: Long-term procedural memory (sensory memory)

## Usage

To play the game with the best experience, follow these steps.

1. Open the app and **enable Bluetooth and GPS**
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

:warning: Disclaimer: This app is only tested on android, as we don't own an iOS device. It is expected to be used on mobile.

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
      <td>:octocat: Custom flutter ESense fork</td>
      <td>:heavy_check_mark:</td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>:twisted_rightwards_arrows: Tab routing with bottom navigation bar</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>:electric_plug: Connect tab</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>:triangular_ruler: Calibrate tab</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>:leftwards_arrow_with_hook: Communicate global state to widgets with event-callbacks</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>:eyes: 3D representation of eareble accelerometer</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>:space_invader: Ingame components (player/ai/ball/blockers)</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>:game_die: Responsive ingame blocker grid generation</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>:rocket: Improved collision detection for fast moving ingame components</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>:arrow_lower_left: Smart collision handling for ingame components</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>:musical_note: Ingame soundeffects and music integration</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>:trophy: Ingame pause and endgame overlay</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>:recycle: Ingame game reset handling</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>:satellite: BLE connection state handling</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>:construction_worker: Failsafe eareable initialization sequence</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>:boom: Unexpected disconnect handling</td>
      <td>:heavy_check_mark:</td>
      <td></td>
    </tr>
    <tr>
      <td>:straight_ruler: Calibration handling</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>:clipboard: Eareable config sensitive calculations (needs custom fork)</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>:dart: Eareable orientation calculation</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
    <tr>
      <td>:postal_horn: Eareable event propagation for Flame components</td>
      <td></td>
      <td>:heavy_check_mark:</td>
    </tr>
  </tbody>
</table>

## Custom Flutter Esense Fork

We created a [custom fork][flutter-esense-fork] for the [flutter_esense package][flutter-esense].
To be able to convert the ESense outputs in usable formats like `g` or `m/s^2`, you have to get the current device configuration. Specifically to convert the accelerometer output, you need the accelerometers sensitivity factor.
The problem is, that the original flutter package didn't map the ESense output to the provided event class ([see here](https://github.com/HydrofinLoewenherz/flutter-plugins/commit/b7d0e74f8717288b76bf748e3230e1341e67e552)). Additionally we added utilities to convert the config values into the sensitivity factors specified in the [ESense specification][esense-specification] ([see here](https://github.com/HydrofinLoewenherz/flutter-plugins/commit/c44c6a45ac12b4a7aefde0cef0c6251a03f52edc)).

## Screenshots

<img width="450" alt="Pongsense connect screen" src="https://user-images.githubusercontent.com/20629648/212373187-06db6f64-d968-47ca-a4ff-ecc56d0588f9.png">
<img width="450" alt="Pongsense calibrate screen" src="https://user-images.githubusercontent.com/20629648/212373181-90ed9fe2-9f60-4f74-8b2e-d1df570801f4.png">
<img width="450" alt="Pongsense play screen" src="https://user-images.githubusercontent.com/20629648/212373194-5e1c2f17-c182-4c57-b574-247a47222833.png">

## Authors

The project was created by [Rico Münch (uozjn)][rico-github] and [Paul Wagner (ujhtl)][paul-github].

## Sources

The **Audio Files** that are used in the project are imported from [Storybooks][storybooks].

The following **Libraries** are used in the project

- [flame][flame] (2D game engine)
- [flame_audio][flame-audio] (audio for Flame)
- [esense_flutter (custom fork)][flutter-esense-fork] (ESense connection)
- [permission_handler][permission-handler] (ask for permissions on android)
- [ditredi][ditredi] (3D visualization package)

See the dependencies in the `pubspec.yml` for more information.

[esense]: https://www.esense.io/ "ESense Homepage"
[esense-specification]: https://www.esense.io/share/eSense-BLE-Specification.pdf "ESense Specification"
[storybooks]: https://www.storyblocks.com/ "Storybooks Stock Media"
[flutter-esense]: https://pub.dev/packages/esense_flutter "Flutter ESense package"
[flutter-esense-fork]: https://github.com/HydrofinLoewenherz/flutter-plugins/tree/master/packages/esense_flutter "Flutter ESense package (custom fork)"
[flame]: https://pub.dev/packages/flame "Flame package"
[flame-audio]: https://pub.dev/packages/flame_audio "Flame audio package"
[permission-handler]: https://pub.dev/packages/permission_handler "Permission handler package"
[permission-handler]: https://pub.dev/packages/permission_handler "Permission handler package"
[ditredi]: https://pub.dev/packages/ditredi "DiTreDi package"
[paul-github]: https://github.com/HydrofinLoewenherz "ujhtl"
[rico-github]: https://github.com/cryeprecision "uozjn"
