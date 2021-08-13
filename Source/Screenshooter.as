string title = "\\$c6f" + Icons::Camera + "\\$z Screenshooter";

CHmsViewport@ viewport = null;

bool visible = false;
bool capturing = false;
string path = "";

bool WarningThreshold(vec2 size)
{
	if (Setting_ResolutionWidth > (size.x * Setting_WarningThreshold)) {
		return true;
	}
		
	if (Setting_ResolutionHeight > (size.y * Setting_WarningThreshold)) {
		return true;
	}

	if (Setting_PanoramaResolution > (2048 * Setting_WarningThreshold)) {
		return true;
	}

	return false;
}

void RenderMenu()
{
	if (UI::MenuItem(title, "", visible))
		visible = !visible;
}

void RenderInterface()
{
	if (visible) {
		vec2 windowSize = vec2(viewport.SystemWindow.SizeX, viewport.SystemWindow.SizeY);
		string typeLabel = Regex::Search(tostring(Setting_Type), "[^::]+$")[0];
		string formatLabel = Regex::Search(tostring(Setting_Format), "[^::]+$")[0];

		UI::Begin(title, visible, UI::WindowFlags::AlwaysAutoResize + UI::WindowFlags::NoDocking);

		if (UI::BeginCombo("Type", typeLabel)) {
			if (UI::Selectable("Regular", false)) {
				Setting_Type = ImageType::Regular;
			}
			if (UI::Selectable("Panorama", false)) {
				Setting_Type = ImageType::Panorama;
			}
			UI::EndCombo();
		}

		if (UI::BeginCombo("Format", formatLabel)) {
			if (UI::Selectable("WebP", false)) {
				Setting_Format = ImageFormat::WebP;
			}
			if (UI::Selectable("JPEG", false)) {
				Setting_Format = ImageFormat::JPEG;
			}
			if (UI::Selectable("TARGA", false)) {
				Setting_Format = ImageFormat::TARGA;
			}
			UI::EndCombo();
		}

		UI::Dummy(vec2(1, 1));

		switch (Setting_Type) {
			case ImageType::Regular:
				Setting_Tiling = UI::Checkbox("Tiling", Setting_Tiling);
				if (UI::IsItemHovered()) {
					UI::BeginTooltip();
					UI::Text("Slice screenshot into separate files");
					UI::EndTooltip();
				}
				if (UI::Button(Icons::ArrowsH)) {
					Setting_ResolutionWidth = int(windowSize.x);
				}
				if (UI::IsItemHovered()) {
					UI::BeginTooltip();
					UI::Text("Stretch to game resolution width");
					UI::EndTooltip();
				}
				UI::SameLine();
				Setting_ResolutionWidth = UI::InputInt("Width", int(Setting_ResolutionWidth));
				if (UI::Button(Icons::ArrowsV)) {
					Setting_ResolutionHeight = int(windowSize.y);
				}
				if (UI::IsItemHovered()) {
					UI::BeginTooltip();
					UI::Text("Stretch to game resolution height");
					UI::EndTooltip();
				}
				UI::SameLine();
				Setting_ResolutionHeight = UI::InputInt("Height", int(Setting_ResolutionHeight));
				if (Setting_Tiling) {
					Setting_TilingX = UI::InputInt("Tiling Horizontal", Setting_TilingX);
					Setting_TilingY = UI::InputInt("Tiling Vertical", Setting_TilingY);
				}
				break;
			case ImageType::Panorama:
				if (UI::Button(Icons::Arrows)) {
					Setting_PanoramaResolution = int(windowSize.y);
				}
				if (UI::IsItemHovered()) {
					UI::BeginTooltip();
					UI::Text("Stretch to game resolution height");
					UI::Text("(width is determined automatically)");
					UI::EndTooltip();
				}
				UI::SameLine();
				Setting_PanoramaResolution = UI::InputInt("Height", Setting_PanoramaResolution);
				break;
		}

		UI::PushStyleColor(UI::Col::Text, vec4(255, 255, 0, 1.f));
		if (WarningThreshold(windowSize)) {
			UI::Dummy(vec2(1, 1));
			UI::Text("Extreme resolution can cause the game to crash");
		}
		if (Setting_Type == ImageType::Panorama && Setting_Format == ImageFormat::TARGA) {
			UI::Dummy(vec2(1, 1));
			UI::Text("TARGA (.tga) with panoramic type will swap Red and Blue colors");
		}
		UI::PopStyleColor();

		UI::Separator();

		if (UI::Button(Icons::Camera + " Capture!") && !capturing) {
			capturing = true;
			startnew(Capture);
		}
		if (path.Length > 0) {
			UI::SameLine();
			if (UI::Button(Icons::FileImageO + " Preview")) {
				cast<CTrackMania>(GetApp()).ManiaPlanetScriptAPI.OpenLink("file:///" + path, CGameManiaPlanetScriptAPI::ELinkType::ExternalBrowser);
			}
		}

		UI::End();
	}
}

void ResetTiles()
{
	if (viewport.ScreenShotTileX != 1) {
		viewport.ScreenShotTileX = 1;
	}
	if (viewport.ScreenShotTileY != 1) {
		viewport.ScreenShotTileY = 1;
	}
}

void Capture()
{
	if (GetApp().GameScene is null && Setting_Type == ImageType::Panorama) {
		UI::ShowNotification(title, "Please enter the game first!");
		capturing = false;
		return;
	}

	if (Setting_ResolutionWidth < 16 || Setting_ResolutionHeight < 16) {
		UI::ShowNotification(title, "Camera resolution is too small!");
		capturing = false;
		return;
	}

	if (Setting_PanoramaResolution < 16) {
		UI::ShowNotification(title, "Panorama resolution is too small!");
		capturing = false;
		return;
	}

	if (Setting_Tiling && (Setting_TilingX < 1 || Setting_TilingY < 1)) {
		UI::ShowNotification(title, "Amount of tiles for slicing is too small!");
		capturing = false;
		return;
	}
	
	// Cubemap is omitted due to glitches
	switch (Setting_Type) {
		case ImageType::Regular:
			// Setting desired screen resolution
			viewport.ScreenShotWidth = int(Setting_ResolutionWidth);
			viewport.ScreenShotHeight = int(Setting_ResolutionHeight);
			if (Setting_Tiling) {
				viewport.ScreenShotTileX = Setting_TilingX;
				viewport.ScreenShotTileY = Setting_TilingY;
			} else {
				ResetTiles();
			}
			viewport.ScreenShot360 = 0;
			break;
		case ImageType::Panorama:
			// Camera resolution must match panorama resolution for a crisp image
			viewport.ScreenShotWidth = Setting_PanoramaResolution;
			viewport.ScreenShotHeight = Setting_PanoramaResolution;
			viewport.ScreenShot360_Height = Setting_PanoramaResolution;
			viewport.ScreenShot360 = 1;
			ResetTiles();
			break;
		default:
			UI::ShowNotification(title, "Unknown image type!");
			capturing = false;
			return;
	}

	// Forcing custom resolution
	viewport.ScreenShotForceRes = true;

	// Waiting for screen resolution to change to the desired one
	yield();

	// DDS is omitted due to glitches
	switch (Setting_Format) {
		case ImageFormat::WebP:
			viewport.ScreenShotDoCaptureWebp();
			break;
		case ImageFormat::JPEG:
			viewport.ScreenShotDoCaptureJpg();
			break;
		case ImageFormat::TARGA:
			viewport.ScreenShotDoCaptureTga();
			break;
		default:
			UI::ShowNotification(title, "Unknown image format!");
			break;
	}

	// Waiting for screenshot to render
	yield();

	// Reverting original resolution
	viewport.ScreenShotForceRes = false;

	// Waiting for screen resolution to change back
	yield();

	// Replacing path with forward slashes for browser support
	path = string(viewport.ScreenShotFullName).Replace("\\", "/");

	// Check if file exists
	// Tiling generates multiple files instead of one
	// Therefore open the game folder instead of a file
	if (!IO::FileExists(path) || (Setting_Tiling && Setting_Type == ImageType::Regular)) {
		path = Regex::Replace(path, "[^/]+$", "");
	}

	// Game doesn't check for permissions and will always output destination
	if (path.Length > 0) {
		UI::ShowNotification(title, path);
	} else {
		UI::ShowNotification(title, "Something went wrong!");
	}

	capturing = false;
}

void Main()
{
	@viewport = GetApp().Viewport;
}