package states;

import core.GameConfig;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class ContactState extends FlxState
{
    
    override public function create():Void {
        super.create();

        FlxG.camera.bgColor = FlxColor.fromRGB(20, 20, 30);

        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;

        try {
            if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
                FlxG.sound.playMusic("assets/music/juanjo_sound - FPS Menu Music Themes v.1.01/juanjo - FPS Menu Music Theme 3.wav", 0.5, true);
            }
        } catch (e:Dynamic) {
            trace("Could not load menu music: " + e);
        }
        
		var titleText = new FlxText(0, 30, GameConfig.SCREEN_W, "CONTACT US & CREDITS");
		titleText.setFormat(null, 32, FlxColor.WHITE, "center");
        titleText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        titleText.scrollFactor.set(0, 0);
        add(titleText);
        
		var yPos = 90;
		var lineSpacing = 28;

		addContactLine("CONTACT US", yPos, FlxColor.fromRGB(100, 200, 255), 22);
		yPos += lineSpacing + 10;

		addContactLine("Email: group4GameProgramming@lakeheadu.ca", yPos, FlxColor.LIME, 14);
		yPos += lineSpacing + 15;

		addContactLine("GAME CREDITS", yPos, FlxColor.fromRGB(255, 200, 100), 22);
		yPos += lineSpacing + 10;

		addContactLine("DEVELOPMENT TEAM", yPos, FlxColor.CYAN, 16);
        yPos += lineSpacing;
        
		addContactLine("Jils Patel - jpate127@lakeheadu.ca", yPos, FlxColor.WHITE, 13);
		yPos += lineSpacing - 5;

		addContactLine("Utsav Patel - upatel29@lakeheadu.ca", yPos, FlxColor.WHITE, 13);
		yPos += lineSpacing - 5;

		addContactLine("Priyansh Patel - ppate186@lakeheadu.ca", yPos, FlxColor.WHITE, 13);
		yPos += lineSpacing - 5;

		addContactLine("Vijay Patel - vpatel99@lakeheadu.ca", yPos, FlxColor.WHITE, 13);
		yPos += lineSpacing - 5;

		addContactLine("Haard Pathak - hpathak1@lakeheadu.ca", yPos, FlxColor.WHITE, 13);
		yPos += lineSpacing - 5;

		addContactLine("Daksh Jariwala - djariwa2@lakeheadu.ca", yPos, FlxColor.WHITE, 13);
		yPos += lineSpacing - 5;

		addContactLine("Margin Patel - mpate138@lakeheadu.ca", yPos, FlxColor.WHITE, 13);
		yPos += lineSpacing + 10;

		addContactLine("SPECIAL THANKS", yPos, FlxColor.fromRGB(255, 150, 255), 16);
        yPos += lineSpacing;
        
		addContactLine("ChatGPT", yPos, FlxColor.fromRGB(200, 200, 255), 14);
		yPos += lineSpacing - 5;

		addContactLine("For helping throughout - providing resources links to the assets", yPos, FlxColor.fromRGB(180, 180, 180), 12);
		yPos += lineSpacing - 8;

		addContactLine("and helping how to develop a game from scratch", yPos, FlxColor.fromRGB(180, 180, 180), 12);
		yPos += lineSpacing + 5;

		var backPrompt = new FlxText(0, GameConfig.SCREEN_H - 60, GameConfig.SCREEN_W, "Press SPACE to go back to menu");
		backPrompt.setFormat(null, 14, FlxColor.YELLOW, "center");
		backPrompt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		backPrompt.scrollFactor.set(0, 0);
		add(backPrompt);

    }
    
    function addContactLine(text:String, y:Float, color:FlxColor, size:Int):Void {
        var line = new FlxText(0, y, GameConfig.SCREEN_W, text);
        line.setFormat(null, size, color, "center");
        line.scrollFactor.set(0, 0);
        add(line);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.SPACE)
		{
			FlxG.switchState(MenuState.new);
        }
    }
}

