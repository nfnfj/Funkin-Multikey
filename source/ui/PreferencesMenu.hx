package ui;

import openfl.Lib;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import haxe.ds.StringMap;

class PreferencesMenu extends Page
{
	public static var preferences:StringMap<Dynamic> = new StringMap<Dynamic>();

	var checkboxes:Array<CheckboxThingie> = [];
	var menuCamera:FlxCamera;
	var items:TextMenuList;
	var camFollow:FlxObject;
	
		#if android
		var tipText:FlxText = new FlxText(10, FlxG.height - 24, 0, 'Press C to customize your android controls', 16);
		tipText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 2.4;
		tipText.scrollFactor.set();
		add(tipText);
		#end

	#if debug
	public static var developer_mode:Bool = true;
	#else
	public static var developer_mode:Bool = false;
	#end

	override public function new()
	{
		super();
		menuCamera = new FlxCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = FlxColor.TRANSPARENT;
		camera = menuCamera;
		add(items = new TextMenuList());

		createPrefItem('naughtyness', 'censor-naughty', true);
		createPrefItem('downscroll', 'downscroll', false);
		createPrefItem('flashing menu', 'flashing-menu', true);
		createPrefItem('Camera Zooming on Beat', 'camera-zoom', true);
		createPrefItem('FPS Counter', 'fps-counter', true);
		createPrefItem('Ghost Tapping', 'ghost-tapping', false);
		createPrefItem('Auto Pause', 'auto-pause', false);
		createPrefItem('Unlimited FPS', 'fps-plus', false);
		createPrefItem('Freeplay Music', 'freeplay-music', true);
		createPrefItem("Freeplay Cutscenes", 'freeplay-cutscenes', false);
		createPrefItem("One Lane", 'one-lane', false);

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		
		if (items != null)
		{
			camFollow.y = items.members[items.selectedIndex].y;
		}
		menuCamera.follow(camFollow, null, 0.06);
		menuCamera.deadzone.set(0, 160, menuCamera.width, 40);
		menuCamera.minScrollY = 0;
		items.onChange.add(function(item:TextMenuItem)
		{
			camFollow.y = item.y;
		});
	}

	public static function getPref(pref:String)
	{
		return preferences.get(pref);
	}
	
		#if android
		if (virtualPad.buttonC.justPressed) {
			#if android
			removeVirtualPad();
			#end
			openSubState(new android.AndroidControlsSubState());
		}
		#end

	public static function initPrefs()
	{
		if(!preferences.exists("downscroll"))
		{
			if(FlxG.save.data.preferences != null)
				preferences = FlxG.save.data.preferences;
		}

		preferenceCheck('censor-naughty', true);
		preferenceCheck('downscroll', false);
		preferenceCheck('flashing-menu', true);
		preferenceCheck('camera-zoom', true);
		preferenceCheck('ghost-tapping', false);
		preferenceCheck('fps-counter', true);
		preferenceCheck('auto-pause', false);
		preferenceCheck('fps-plus', false);
		preferenceCheck('freeplay-music', true);
		preferenceCheck('master-volume', 1);
		preferenceCheck('freeplay-cutscenes', false);
		preferenceCheck('one-lane', false);

		if (!getPref('fps-counter'))
		{
			Lib.current.stage.removeChild(Main.fpsCounter);
		}

		FlxG.autoPause = getPref('auto-pause');

		FlxG.save.data.preferences = preferences;
		FlxG.save.flush();
	}

	public static function preferenceCheck(identifier:String, defaultValue:Dynamic)
	{
		if (preferences.get(identifier) == null)
		{
			preferences.set(identifier, defaultValue);
			trace('set preference!');

			FlxG.save.data.preferences = preferences;
			FlxG.save.flush();
		}
		else
		{
			trace('found preference: ' + Std.string(preferences.get(identifier)));
		}
	}

	public function createPrefItem(label:String, identifier:String, value:Dynamic)
	{
		items.createItem(120, 120 * items.length + 30, label, Bold, function()
		{
			preferenceCheck(identifier, value);
			if (Type.typeof(value) == TBool)
			{
				prefToggle(identifier);
			}
			else
			{
				trace('swag');
			}
		});
		if (Type.typeof(value) == TBool)
		{
			createCheckbox(identifier);
		}
		else
		{
			trace('swag');
		}
		trace(Type.typeof(value));
	}

	public function createCheckbox(identifier:String)
	{
		var box:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), preferences.get(identifier));
		checkboxes.push(box);
		add(box);
	}

	public function prefToggle(identifier:String)
	{
		var value:Bool = preferences.get(identifier);
		value = !value;
		preferences.set(identifier, value);
		checkboxes[items.selectedIndex].daValue = value;
		trace('toggled? ' + Std.string(preferences.get(identifier)));
		switch (identifier)
		{
			case 'auto-pause':
				FlxG.autoPause = getPref('auto-pause');
			case 'fps-counter':
				if (getPref('fps-counter'))
					Lib.current.stage.addChild(Main.fpsCounter);
				else
					Lib.current.stage.removeChild(Main.fpsCounter);
		}

		FlxG.save.data.preferences = preferences;
		FlxG.save.flush();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		menuCamera.followLerp = CoolUtil.camLerpShit(0.05);
		items.forEach(function(item:MenuItem)
		{
			if (item == items.members[items.selectedIndex])
				item.x = 150;
			else
				item.x = 120;
		});
	}
}