string title = "\\$c6f" + Icons::Camera + "\\$z Screenshooter";

CHmsViewport@ viewport = null;

bool visible = false;
bool capturing = false;
bool panic = false;
string path = "";

bool WarningThreshold(vec2 size)
{
	if (Setting_ResolutionWidth > (size.x * Setting_WarningThreshold)) {
		return true;
	}
		
	if (Setting_ResolutionHeight > (size.y * Setting_WarningThreshold)) {
		return true;
	}

#if MP4
	if (Setting_PanoramaResolution > (2048 * Setting_WarningThreshold)) {
		return true;
	}
#endif

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

#if MP4
		if (UI::BeginCombo("Type", typeLabel)) {
			if (UI::Selectable("Regular (frame)", false)) {
				Setting_Type = ImageType::Regular;
			}
			if (UI::Selectable("Panorama (360)", false)) {
				Setting_Type = ImageType::Panorama;
			}
			UI::EndCombo();
		}
#endif

		if (UI::BeginCombo("Format", formatLabel)) {
			if (UI::Selectable("WebP (slow)", false)) {
				Setting_Format = ImageFormat::WebP;
			}
			if (UI::Selectable("JPEG (fast)", false)) {
				Setting_Format = ImageFormat::JPEG;
			}
			if (UI::Selectable("TARGA (fastest)", false)) {
				Setting_Format = ImageFormat::TARGA;
			}
			UI::EndCombo();
		}

		UI::Dummy(vec2(1, 1));

		Setting_Sequence = UI::Checkbox("Sequence", Setting_Sequence);
		if (UI::IsItemHovered()) {
			UI::BeginTooltip();
			UI::Text("Capture several frames at a time");
			UI::Text("(framerate depends on performance)");
			UI::EndTooltip();
		}
		if (Setting_Sequence) {
			Setting_Frames = UI::SliderInt("Frames", Setting_Frames, 2, 99);
		}

		switch (Setting_Type) {
			case ImageType::Regular:
#if MP4
				Setting_Tiling = UI::Checkbox("Tiling", Setting_Tiling);
				if (UI::IsItemHovered()) {
					UI::BeginTooltip();
					UI::Text("Slice frame into separate files");
					UI::Text("(useful for high resolution frames)");
					UI::EndTooltip();
				}
				if (Setting_Tiling) {
					Setting_TilingX = UI::InputInt("Tiling Horizontal", Setting_TilingX);
					Setting_TilingY = UI::InputInt("Tiling Vertical", Setting_TilingY);
				}
#endif

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
				break;
#if MP4
			case ImageType::Panorama:
				Setting_PanoramaFix = UI::Checkbox("Fix Tiles", Setting_PanoramaFix);
				if (UI::IsItemHovered()) {
					UI::BeginTooltip();
					UI::Text("Fixes misplaced tiles in panoramic mode while sacrificing quality");
					UI::Text("(most maps have misplaced tiles, the cause is yet to be found)");
					UI::EndTooltip();
				}
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
#endif
		}

		UI::PushStyleColor(UI::Col::Text, vec4(255, 255, 0, 1.f));
		if (WarningThreshold(windowSize)) {
			UI::Dummy(vec2(1, 1));
			UI::Text("Extreme resolution can cause the game to crash");
		}
		if (Setting_Format == ImageFormat::TARGA) {
			UI::Dummy(vec2(1, 1));
			UI::Text("TARGA (.tga) is a raw format which will result in huge file size");
#if MP4
			if (Setting_Type == ImageType::Panorama) {
				UI::Dummy(vec2(1, 1));
				UI::Text("TARGA (.tga) with panoramic type will swap Red and Blue colors");
			}
#endif
		}
#if MP4
		if (Setting_Sequence) {
			if (Setting_Type == ImageType::Regular && Setting_Tiling) {
				UI::Dummy(vec2(1, 1));
				UI::Text("Sequence and tiling will cause the screen to flash rapidly");
			}
			if (Setting_Type == ImageType::Panorama) {
				UI::Dummy(vec2(1, 1));
				UI::Text("Sequence and panorama will cause the screen to flash rapidly");
			}
		}
#endif
		UI::PopStyleColor();

		UI::Separator();

		if (!capturing) {
			if (UI::Button(Icons::Camera + " Capture")) {
				startnew(Capture);
			}
		} else if (!panic) {
			UI::PushStyleColor(UI::Col::Button, vec4(1.f, 0.1, 0.1, 1.f));
			UI::PushStyleColor(UI::Col::ButtonHovered, vec4(1.f, 0.25, 0.25, 1.f));
			UI::PushStyleColor(UI::Col::ButtonActive, vec4(1.f, 0, 0, 1.f));
			if (UI::Button(Icons::Stop + " Stop")) {
				panic = true;
			}
			UI::PopStyleColor(3);
		}
		if (path.Length > 0) {
			UI::SameLine();
			if (UI::Button(Icons::FileImageO + " Preview")) {
				cast<CTrackMania>(GetApp()).ManiaPlanetScriptAPI.OpenLink("file:///" + path, CGameManiaPlanetScriptAPI::ELinkType::ExternalBrowser);
			}
		}

		vec4 transparency = vec4(0, 0, 0, 0);

		UI::PushStyleColor(UI::Col::Button, transparency);
		UI::PushStyleColor(UI::Col::ButtonHovered, transparency);
		UI::PushStyleColor(UI::Col::ButtonActive, transparency);

		// Buttons and shortcuts tooltip
		if (Setting_TipButtons) {
			UI::SameLine();
			UI::Button(Icons::QuestionCircle);
			if (UI::IsItemHovered()) {
				UI::BeginTooltip();
				string startShortcutString = "";
				string stopShortcutString = "";
				if (Setting_KeyboardShortcuts) {
					startShortcutString = " (or \\$66f" + Icons::KeyboardO + " " + tostring(Setting_StartCapturingKey) + " \\$zkey)";
					stopShortcutString = " (or \\$66f" + Icons::KeyboardO + " " + tostring(Setting_StopCapturingKey) + " \\$zkey)";
				}
				UI::Text("To start capturing, press the \\$4cf" + Icons::Camera + " Capture \\$zbutton" + startShortcutString + " once.");
				UI::Text("To stop capturing, press and hold the \\$f66" + Icons::Stop + " Stop \\$zbutton" + stopShortcutString + " until next frame, then release.");
				if (!Setting_KeyboardShortcuts) {
					UI::Separator();
					UI::Text("\\$ff0You can enable " + Icons::KeyboardO + " keyboard shortcuts in plugin settings\\$z");
				}
				UI::EndTooltip();
			}
		}

#if TMNEXT
		// Disclaimer about broken features after TMNEXT update
		if (Setting_TipDisclaimer) {
			UI::SameLine();
			if (UI::Button(Icons::ExclamationCircle)) {
				Setting_TipDisclaimer = false;
			}
			if (UI::IsItemHovered()) {
				UI::BeginTooltip();
				UI::Text("Since around \\$777November 2021\\$z the \\$777360 Panorama\\$z and \\$777Tiling\\$z features are no longer working for no particular reason.");
				UI::Text("Everything works fine in \\$777ManiaPlanet\\$z. The update probably broke these two features.");
				UI::Text("Because \\$777OpenPlanet\\$z is not officially supported the developers can't do anything about it.");
				UI::Text("I am very sad about this and maybe in the future the plugin will work again.");
				UI::Dummy(vec2(1, 1));
				UI::Text("Thank you for using \\$c6fScreenshooter " + Icons::Heartbeat + "\\$z");
				UI::Separator();
				UI::Text("\\$ff0" + Icons::Kenney::MouseLeftButton + " left click to hide the disclaimer");
				UI::EndTooltip();
			}
		}
#endif

		UI::PopStyleColor(3);

		UI::End();
	}
}

#if MP4
void ResetTiles()
{
	if (viewport.ScreenShotTileX != 1) {
		viewport.ScreenShotTileX = 1;
	}
	if (viewport.ScreenShotTileY != 1) {
		viewport.ScreenShotTileY = 1;
	}
}
#endif

void Capture()
{
	capturing = true;

#if MP4
	if (GetApp().GameScene is null && Setting_Type == ImageType::Panorama) {
#else
	if (GetApp().GameScene is null) {
#endif
		UI::ShowNotification(title, "Please enter the game first!");
		capturing = false;
		return;
	}

	if (Setting_ResolutionWidth < 16 || Setting_ResolutionHeight < 16) {
		UI::ShowNotification(title, "Camera resolution is too small!");
		capturing = false;
		return;
	}

#if MP4
	if (Setting_PanoramaResolution < 16) {
		UI::ShowNotification(title, "Panorama resolution is too small!");
		capturing = false;
		return;
	}

	if (Setting_Tiling && (Setting_TilingX + Setting_TilingY) < 3) {
		UI::ShowNotification(title, "Amount of tiles for slicing is too small!");
		capturing = false;
		return;
	}
#endif

	if (Setting_Sequence && (Setting_Frames < 2 || Setting_Frames > 99)) {
		UI::ShowNotification(title, "Amount of frames is out of bounds!");
		capturing = false;
		return;
	}
	
	// Cubemap is omitted due to glitches
	switch (Setting_Type) {
		case ImageType::Regular:
			// Setting desired screen resolution
			viewport.ScreenShotWidth = int(Setting_ResolutionWidth);
			viewport.ScreenShotHeight = int(Setting_ResolutionHeight);
#if MP4
			if (Setting_Tiling) {
				viewport.ScreenShotTileX = Setting_TilingX;
				viewport.ScreenShotTileY = Setting_TilingY;
			} else {
				ResetTiles();
			}

			viewport.ScreenShot360 = 0;
#endif
			break;
#if MP4
		case ImageType::Panorama:
			// Camera resolution must match panorama resolution for a crisp image
			viewport.ScreenShotWidth = Setting_PanoramaResolution;
			viewport.ScreenShotHeight = Setting_PanoramaResolution;
			viewport.ScreenShot360_Height = Setting_PanoramaResolution;
			viewport.ScreenShot360 = 1;
			if (Setting_PanoramaFix) {
				// For some reason different rendering mode causes the tiles to be in the right place
				// Though they might become horizontally inverted
				// Some maps work fine without the workaround
				// (e.g. try to create a new map in editor and test the panorama capturing)
				viewport.Cameras[1].UseViewDependantRendering = false;
			}
			ResetTiles();
			break;
#endif
		default:
			UI::ShowNotification(title, "Unknown image type!");
			capturing = false;
			return;
	}

	// Forcing custom resolution
	viewport.ScreenShotForceRes = true;

	// Waiting for screen resolution to change to the desired one
	yield();

	// Check if we need to capture several frames
	if (Setting_Sequence) {
		// Multiple capture
		for (int i = 0; i < Setting_Frames; i++) {
			if (panic) {
				break;
			}
			Screenshoot();
		}
	} else {
		// Single capture
		Screenshoot();
	}

#if MP4
	// Reverting different rendering mode
	if (Setting_PanoramaFix) {
		viewport.Cameras[1].UseViewDependantRendering = true;
	}
#endif

	// Reverting original resolution
	viewport.ScreenShotForceRes = false;

	// Waiting for screen resolution to change back
	yield();

	// Replacing path with forward slashes for browser support
	path = string(viewport.ScreenShotFullName).Replace("\\", "/");

	// Check if file exists
	// Tiling generates multiple files instead of one
	// Therefore open the game folder instead of a file
#if MP4
	if (!IO::FileExists(path) || (Setting_Tiling && Setting_Type == ImageType::Regular)) {
#else
	if (!IO::FileExists(path)) {
#endif
		path = Regex::Replace(path, "[^/]+$", "");
	}

	if (panic) {
		UI::ShowNotification(title, "Capturing stopped!");
	}

	// Game doesn't check for permissions and will always output destination
	if (path.Length > 0) {
		UI::ShowNotification(title, path);
	} else {
		UI::ShowNotification(title, "Something went wrong!");
	}

	panic = false;
	capturing = false;
}

void Screenshoot()
{
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

	// Waiting for frame to render
	yield();
}

bool OnKeyPress(bool down, VirtualKey key)
{
	if (Setting_KeyboardShortcuts && down) {
		if (!capturing && key == Setting_StartCapturingKey) {
			startnew(Capture);
		} else if (!panic && key == Setting_StopCapturingKey) {
			panic = true;
		}
	}
	return false;
}

void Main()
{
	@viewport = GetApp().Viewport;
}