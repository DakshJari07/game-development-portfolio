package states;

import core.GameConfig;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class TutorialState extends FlxState {
    var titleText:FlxText;
    var promptText:FlxText;
    var canExit:Bool = true;
    
    var controlLabels:Array<String> = [];
    var controlDescriptions:Array<String> = [];
    
    override public function create():Void {
        super.create();
        
        FlxG.camera.bgColor = FlxColor.fromRGB(15, 15, 25);
        
        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;
        
        setupControls();
        
        titleText = new FlxText(0, 40, GameConfig.SCREEN_W, "CONTROLS & KEY BINDS");
        titleText.setFormat(null, 42, FlxColor.WHITE, "center");
        titleText.setBorderStyle(OUTLINE, FlxColor.fromRGB(100, 150, 255), 3);
        titleText.scrollFactor.set(0, 0);
        add(titleText);
        
        var subtitle = new FlxText(0, 95, GameConfig.SCREEN_W, "Master these controls to survive!");
        subtitle.setFormat(null, 16, FlxColor.GRAY, "center");
        subtitle.scrollFactor.set(0, 0);
        add(subtitle);
        
        createControlsDisplay();
        
        createObjectiveSection();
        
        promptText = new FlxText(0, GameConfig.SCREEN_H - 60, GameConfig.SCREEN_W, "Press SPACE to go back to menu");
        promptText.setFormat(null, 14, FlxColor.YELLOW, "center");
        promptText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        promptText.scrollFactor.set(0, 0);
        add(promptText);
        
        FlxTween.tween(promptText, {alpha: 0.5}, 0.8, {
            ease: FlxEase.sineInOut,
            type: PINGPONG
        });
        
        try {
            if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
                FlxG.sound.playMusic("assets/music/juanjo_sound - FPS Menu Music Themes v.1.01/juanjo - FPS Menu Music Theme 3.wav", 0.5, true);
            }
        } catch (e:Dynamic) {
            trace("Could not load menu music: " + e);
        }
    }
    
    function setupControls():Void {
        controlLabels.push("W / A / S / D");
        controlDescriptions.push("Move Forward / Left / Backward / Right");
        
        controlLabels.push("MOUSE MOVEMENT");
        controlDescriptions.push("Look Around / Aim");
        
        controlLabels.push("LEFT CLICK");
        controlDescriptions.push("Shoot/Fire bullet");
        
        controlLabels.push("R KEY");
        controlDescriptions.push("Reload Weapon");
        
        controlLabels.push("SHIFT (Hold)");
        controlDescriptions.push("Sprint");
        
    }
    
    function createControlsDisplay():Void {
        var startY = 140;
        var lineHeight = 50;
        var leftPadding = 60;
        
        for (i in 0...controlLabels.length) {
            var yPos = startY + (i * lineHeight);
            
            var keyText = new FlxText(leftPadding, yPos, 300, controlLabels[i]);
            keyText.setFormat(null, 16, FlxColor.CYAN, "left", OUTLINE, FlxColor.BLACK);
            keyText.scrollFactor.set(0, 0);
            keyText.alpha = 0;
            add(keyText);
            
            var separator = new FlxText(leftPadding + 310, yPos, 40, "-");
            separator.setFormat(null, 16, FlxColor.GRAY, "center");
            separator.scrollFactor.set(0, 0);
            separator.alpha = 0;
            add(separator);
            
            var descText = new FlxText(leftPadding + 350, yPos, 500, controlDescriptions[i]);
            descText.setFormat(null, 16, FlxColor.WHITE, "left");
            descText.scrollFactor.set(0, 0);
            descText.alpha = 0;
            add(descText);
            
            FlxTween.tween(keyText, {alpha: 1}, 0.5, {
                startDelay: i * 0.1,
                ease: FlxEase.quadOut
            });
            FlxTween.tween(separator, {alpha: 1}, 0.5, {
                startDelay: i * 0.1,
                ease: FlxEase.quadOut
            });
            FlxTween.tween(descText, {alpha: 1}, 0.5, {
                startDelay: i * 0.1,
                ease: FlxEase.quadOut
            });
        }
    }
    
    
    function createObjectiveSection():Void {
        var objY = 400;
        
        var objHeader = new FlxText(60, objY, GameConfig.SCREEN_W - 120, "MISSION OBJECTIVE:");
        objHeader.setFormat(null, 20, FlxColor.fromRGB(255, 100, 100), "left", OUTLINE, FlxColor.BLACK);
        objHeader.scrollFactor.set(0, 0);
        objHeader.alpha = 0;
        add(objHeader);
        
        var objText = new FlxText(80, objY + 30, GameConfig.SCREEN_W - 160, 
            "Eliminate all enemies before time runs out!");
        objText.setFormat(null, 14, FlxColor.WHITE, "left");
        objText.scrollFactor.set(0, 0);
        objText.alpha = 0;
        add(objText);
        
        FlxTween.tween(objHeader, {alpha: 1}, 0.5, {startDelay: 1.6});
        FlxTween.tween(objText, {alpha: 1}, 0.5, {startDelay: 1.8});
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        if (canExit && (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.SPACE)) {
            returnToMenu();
        }
    }
    
    function returnToMenu():Void {
        canExit = false;
        FlxG.switchState(MenuState.new);
    }
}