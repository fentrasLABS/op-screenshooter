[Setting name="Resolution Width" description="Image width for regular screenshots"]
int Setting_ResolutionWidth = 1920;

[Setting name="Resolution Height" description="Image height for regular screenshots"]
int Setting_ResolutionHeight = 1080;

[Setting name="Tiling" description="Slice screenshot into separate files"]
bool Setting_Tiling = false;

[Setting name="Tiling Horizontal" description="Slice screenshot X times horizontally"]
int Setting_TilingX = 1;

[Setting name="Tiling Vertical" description="Slice screenshot Y times vertically"]
int Setting_TilingY = 1;

[Setting name="Panorama Resolution" description="Image resolution for panoramic (360) screenshots"]
int Setting_PanoramaResolution = 4096;

[Setting name="Output Type" description="Image output rendering type"]
ImageType Setting_Type = ImageType::Regular;

[Setting name="Output Format" description="Image output file format"]
ImageFormat Setting_Format = ImageFormat::WebP;

[Setting name="Warning Threshold" description="Show a warning when resolution goes above base resolution multiplied x times" hidden]
int Setting_WarningThreshold = 4;

enum ImageType
{
	Regular,
	Panorama
}

enum ImageFormat
{
	WebP,
	JPEG,
	TARGA
}