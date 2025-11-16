package states;

import core.GameConfig;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class SplashState extends FlxState {
    var titleText:FlxText;
    var promptText:FlxText;
    var canStart:Bool = true;
    
    override public function create():Void {
        super.create();

        FlxG.camera.bgColor = FlxColor.fromRGB(10, 10, 20);

        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;

        titleText = new FlxText(0, GameConfig.SCREEN_H / 2 - 100, GameConfig.SCREEN_W, "HOSTAGE ESCAPER");
        titleText.setFormat(null, 56, FlxColor.WHITE, "center");
        titleText.setBorderStyle(OUTLINE, FlxColor.fromRGB(200, 50, 50), 4);
        titleText.scrollFactor.set(0, 0);
        add(titleText);

        var subtitle = new FlxText(0, GameConfig.SCREEN_H / 2 - 30, GameConfig.SCREEN_W, "A First Person Shooter Experience");
        subtitle.setFormat(null, 18, FlxColor.GRAY, "center");
        subtitle.scrollFactor.set(0, 0);
        add(subtitle);

        promptText = new FlxText(0, GameConfig.SCREEN_H / 2 + 60, GameConfig.SCREEN_W, "CLICK ANYWHERE TO START");
        promptText.setFormat(null, 20, FlxColor.LIME, "center");
        promptText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        promptText.scrollFactor.set(0, 0);
        add(promptText);

    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (canStart && (FlxG.mouse.justPressed || FlxG.keys.justPressed.ANY)) {
            canStart = false;
            startGame();
        }
    }
    
	function startGame():Void
	{
        try {
            FlxG.sound.playMusic("assets/music/juanjo_sound - FPS Menu Music Themes v.1.01/juanjo - FPS Menu Music Theme 3.wav", 0.5, true);
        } catch (e:Dynamic) {
            trace("Could not load menu music: " + e);
        }

        FlxG.switchState(MenuState.new);
    }
}

