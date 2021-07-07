package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
#if desktop
import systools.Dialogs;
#end
#if debug
import flixel.addons.studio.FlxStudio;
#end

class Main extends Sprite
{
	var memoryMonitor:MemoryMonitor = new MemoryMonitor(10, 10, 0xffffff);

	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).

	var initialState:Class<FlxState> = WarningState; // The FlxState the game starts with.

	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if debug
		initialState = AmongUsState;
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, skipSplash, startFullscreen));

		#if (web && debug)
		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			FlxG.addChildBelowMouse(VideoState.playVideo(Paths.video('polyEngine')));
		});
		#end

		#if desktop
		if (PlayState.isBetaVer)
		{
			trace("beta ver!");
			Dialogs.message("Friday Night Funkin' - PolyEngine",
				"This is a beta version of PolyEngine, therefore, bugs are possible to appear. If you notice one, make an issue or a pull request. Thanks.",
				false);
		}
		#end

		#if (!web && !mobile)
		addChild(memoryMonitor);
		#else
		js.Browser.console.warn("MemoryMonitor can't work on JavaScript for some strange reason...");
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end

		#if debug
		flixel.addons.studio.FlxStudio.create();
		#end

		#if desktop
		Lib.current.stage.frameRate = 120;
		#end
	}
}
