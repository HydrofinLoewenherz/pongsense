# Pongsense

Pongsense is a simple implementation of Pong with flutter (for android). But with a twist, the player paddle is controlled with the [ESense Earable][esense].

As the player leans to the left and right, the paddle follows. This gives an interactive and dynamic way to play an old classic.

## Usage

To play the game with the best experience, follow these steps.

1. Open the app
2. Allow the required app permissions
3. Start your [ESense Earable][esense]
4. Click on `Connect` and wait until the status says `initialized`
5. Click on `Calibrate` and follow the shown instructions
6. On the top left, change to the game
7. Have fun :smile:

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
      <td>:tongue: TODO</td>
      <td>:heavy_check_mark:</td>
      <td></td>
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

- [flame][flame] (2D game library)
- [flame_audio][flame-audio] (audio in game)
- [esense_flutter (custom fork)][flutter-esense-fork] (esense connection)
- permission_handler
- ditredi

See the dependencies in the `pubspec.yml` for more information.

[esense]: https://www.esense.io/ "ESense Homepage"
[esense-specification]: https://www.esense.io/share/eSense-BLE-Specification.pdf "ESense Specification"

[storybooks]: https://www.storyblocks.com/ "Storybooks Stock Media"

[flutter-esense]: https://pub.dev/packages/esense_flutter "Flutter Esense Package"
[flutter-esense-fork]: https://github.com/HydrofinLoewenherz/flutter-plugins/tree/master/packages/esense_flutter "Flutter Esense Package (Custom Fork)"
[flame]: https://pub.dev/packages/flame "Flame Package"
[flame-audio]: https://pub.dev/packages/flame_audio "Flame Audio Package"

[paul-github]: https://github.com/HydrofinLoewenherz "ujhtl""
[rico-github]: https://github.com/cryeprecision "uozjn"
