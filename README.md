# Screenshooter <sup><sub>ManiaPlanet Trackmania</sub></sup>
Plugin for OpenPlanet that enhances in-game screenshot feature.

## Features
* Custom resolution (from 16x16 to 8K and more)
* 3 output formats 
    * `.webp` (slow, invisible compression, small file size)
    * `.jpg` (fast, visible compression, smallest file size)
    * `.tga` (fastest, lossless, huge file size)
* 360 Panorama (equirectangular)
* Tiling (for super-resolution screenshots)
* Sequential capturing (99 frames maximum, captured each 10th of a second)

## Limitations
* 99 screenshots in the folder will cause overwriting (starting from the first one)
* Extreme resolutions can cause crashes (16K and more)
* Tiling is available only in *ManiaPlanet* (missing top row)
* Panorama mode
    * Available only in *ManiaPlanet* (*Trackmania2020* crashes)
    * Most maps cause flipped tiles (fixable using *Fix Tiles* option sacrificing quality)
        * The cause is yet to be found
    * TARGA (`.tga`) flips *Red* and *Blue* color channels
    * Noticeable seams due to dynamic camera

## Download
* [OpenPlanet](https://openplanet.nl/files/117)
* [Releases](https://gitlab.com/DergnNamedSkye/op-screenshooter/-/releases)

## Media
![Plugin Windows](_git/1.png)
[![CCP#12 - [PF] Satelite Delivery in 360](_git/2_preview.png)](_git/2.png)
[![Tiling feature in 64K](_git/3_preview.png)](_git/3.webm)
[![Sequential Capturing feature in 360](_git/4_preview.png)](_git/4.webm)

## Credits
Project icon provided by [Fork Awesome](https://forkaweso.me/)
