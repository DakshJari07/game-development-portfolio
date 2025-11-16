package states;

import core.GameConfig;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
#if sys
import Sys;
#end
#if (html5 || web)
import openfl.Lib;
#end

class MenuState extends FlxState {
    var titleText:FlxText;
    var playButton:FlxButton;
    var tutorialButton:FlxButton;
    var contactButton:FlxButton;
    var exitButton:FlxButton;
    
    override public function create():Void {
        super.create();

        FlxG.camera.bgColor = FlxColor.fromRGB(20, 20, 30);

        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;

        titleText = new FlxText(0, 80, GameConfig.SCREEN_W, "HOSTAGE ESCAPER");
        titleText.setFormat(null, 48, FlxColor.WHITE, "center");
        titleText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
        titleText.scrollFactor.set(0, 0);
        add(titleText);

        var subtitle = new FlxText(0, 150, GameConfig.SCREEN_W, "A First Person Shooter Experience");
        subtitle.setFormat(null, 16, FlxColor.GRAY, "center");
        subtitle.scrollFactor.set(0, 0);
        add(subtitle);

        var buttonWidth = 200;
        var buttonHeight = 40;
        var buttonX = (GameConfig.SCREEN_W - buttonWidth) / 2;
        var startY = 220;
        var buttonSpacing = 60;

        playButton = new FlxButton(buttonX, startY, "PLAY", onPlayClick);
        playButton.setSize(buttonWidth, buttonHeight);
        styleButton(playButton, FlxColor.fromRGB(50, 150, 50));
        add(playButton);
        
		tutorialButton = new FlxButton(buttonX, startY + buttonSpacing, "CONTROLS & KEY BINDS", onTutorialClick);
        tutorialButton.setSize(buttonWidth, buttonHeight);
        styleButton(tutorialButton, FlxColor.fromRGB(50, 100, 200));
        add(tutorialButton);
        
		contactButton = new FlxButton(buttonX, startY + buttonSpacing * 2, "CONTACT US & CREDITS", onContactClick);
        contactButton.setSize(buttonWidth, buttonHeight);
        styleButton(contactButton, FlxColor.fromRGB(200, 100, 50));
        add(contactButton);

        exitButton = new FlxButton(buttonX, startY + buttonSpacing * 3, "EXIT", onExitClick);
        exitButton.setSize(buttonWidth, buttonHeight);
        styleButton(exitButton, FlxColor.fromRGB(150, 50, 50));
        add(exitButton);

        try {
            if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
                FlxG.sound.playMusic("assets/music/juanjo_sound - FPS Menu Music Themes v.1.01/juanjo - FPS Menu Music Theme 3.wav", 0.5, true);
            }
        } catch (e:Dynamic) {
            trace("Could not load menu music: " + e);
        }
    }
    
    function styleButton(button:FlxButton, color:FlxColor):Void {
        button.label.setFormat(null, 16, FlxColor.WHITE, "center");
        button.label.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

        var normalColor = color;
        var hoverColor = FlxColor.fromRGB(
            Std.int(Math.min(255, normalColor.red * 1.3)),
            Std.int(Math.min(255, normalColor.green * 1.3)),
            Std.int(Math.min(255, normalColor.blue * 1.3))
        );
        
        button.makeGraphic(Std.int(button.width), Std.int(button.height), normalColor);
        button.onOver.callback = function() {
            button.makeGraphic(Std.int(button.width), Std.int(button.height), hoverColor);
        };
        button.onOut.callback = function() {
            button.makeGraphic(Std.int(button.width), Std.int(button.height), normalColor);
        };
    }
    
	function onPlayClick():Void
	{
        FlxG.switchState(PlayState.new);
    }
    
    function onTutorialClick():Void {
		FlxG.switchState(TutorialState.new);
    }
    
	function onContactClick():Void
	{
        FlxG.switchState(ContactState.new);
    }
    
    function onExitClick():Void {
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		#if sys
		Sys.exit(0);
		#elseif (html5 || web)
		FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
		{
			FlxG.sound.destroy(true);
			clear();

			var exitMsg = new FlxText(0, GameConfig.SCREEN_H / 2 - 30, GameConfig.SCREEN_W, "GAME CLOSED\n\nYou can now close this browser tab");
			exitMsg.setFormat(null, 24, FlxColor.WHITE, "center");
			exitMsg.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
			exitMsg.scrollFactor.set(0, 0);
			add(exitMsg);
		});
		#else
        Sys.exit(0);
        #end
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE) {
            onExitClick();
        }
    }
}

