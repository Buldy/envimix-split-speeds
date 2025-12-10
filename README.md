This plugin is based on the OpenPlanet plugin [Split Speeds](https://openplanet.dev/plugin/splitspeeds) by RuteNL. Changes were made so that you can save split speeds from **all cars** in the titlepacks _Nadeo Envimix_ and _Envimix Turbo_ (or any other MP4 envimix maps that differentiate by changing the MapName attribute). Tested in MP4, should in theory work in TM2020 and Turbo as well but it lacks a purpose.

## **Original descriprion below**




This plugin shows your current speed and your speed difference to your personal best at checkpoint splits, similar to how you can see your time and time difference to your PB in the base game.

## Configuration
This plugin has a few tweakable settings:
* Colour shown when ahead of pb speed (default is green).
* Colour shown when behind pb speed (default is orange).
* Whether to show only the difference in speed, the current speed, or both.
* Toggle to show when in game GUI is hidden or not.
* Change size or position using settings.
* Toggle to compare to session pb or actual pb

## Bug reports
Bug reports are most welcome [on GitHub](https://github.com/RuurdBijlsma/tm-split-speeds/issues). Contributions via pull requests are also welcome.

## Source code
The source code of this plugin is [on GitHub](https://github.com/RuurdBijlsma/tm-split-speeds).

## Limitations
* You have to have driven a time while having this plugin installed for it to register. PB speeds per map are stored in the Openplanet user folder.
* The speeds can vary by at most ~.5 km/h, this isn't a big issue since the speeds are rounded to the nearest integer anyways. It's possible to see a speed difference of 1 km/h on pf maps because of this.
