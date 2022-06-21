[Setting name="Enable" category="Shortcuts"]
bool Setting_KeyboardShortcuts = false;

[Setting name="Start Capturing" category="Shortcuts"]
VirtualKey Setting_StartCapturingKey = VirtualKey::Tab;

[Setting name="Stop Capturing" category="Shortcuts"]
VirtualKey Setting_StopCapturingKey = VirtualKey::Capital;

[Setting name="Buttons and Shortcuts" category="Hints"]
bool Setting_TipButtons = true;

#if TMNEXT
[Setting name="TM2020 Disclaimer" category="Hints"]
bool Setting_TipDisclaimer = true;
#endif

[Setting name="Resolution Width" description="Image width for regular screenshots" category="Parameters"]
int Setting_ResolutionWidth = 1920;

[Setting name="Resolution Height" description="Image height for regular screenshots" category="Parameters"]
int Setting_ResolutionHeight = 1080;

#if MP4
[Setting name="Tiling" description="Slice frame into separate files" category="Parameters"]
bool Setting_Tiling = false;
#endif

[Setting name="Sequence" description="Capture several frames at a time" category="Parameters"]
bool Setting_Sequence = false;

#if MP4
[Setting name="Fix Tiles" description="Fixes misplaced tiles in panoramic mode while sacrificing quality" category="Parameters"]
bool Setting_PanoramaFix = false;

[Setting name="Tiling Horizontal" description="Slice screenshot X times horizontally" category="Parameters"]
int Setting_TilingX = 2;

[Setting name="Tiling Vertical" description="Slice screenshot Y times vertically" category="Parameters"]
int Setting_TilingY = 2;
#endif

[Setting name="Frames" description="Amount of frames to capture sequentially" category="Parameters"]
int Setting_Frames = 99;

#if MP4
[Setting name="Panorama Resolution" description="Image resolution for panoramic (360) screenshots" category="Parameters"]
int Setting_PanoramaResolution = 4096;
#endif

[Setting name="Output Type" description="Image output rendering type" category="Parameters"]
ImageType Setting_Type = ImageType::Regular;

[Setting name="Output Format" description="Image output file format" category="Parameters"]
ImageFormat Setting_Format = ImageFormat::WebP;

[Setting name="Warning Threshold" description="Show a warning when resolution goes above base resolution multiplied x times" category="Parameters" hidden]
int Setting_WarningThreshold = 4;

enum ImageType
{
#if MP4
	Regular,
	Panorama
#else
	Regular
#endif
}

enum ImageFormat
{
	WebP,
	JPEG,
	TARGA
}