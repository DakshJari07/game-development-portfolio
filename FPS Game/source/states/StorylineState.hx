package states;

import core.GameConfig;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class StorylineState extends FlxState {
    var currentImageIndex:Int = 0;
    var totalImages:Int = 5;
    var currentSprite:FlxSprite;
    var promptText:FlxText;
    var canAdvance:Bool = true;
    var fadeTween:FlxTween;

    var imagePaths:Array<String> = [
        "assets/images/Story line/1.png",
        "assets/images/Story line/2.png",
        "assets/images/Story line/3.png",
        "assets/images/Story line/4.png",
        "assets/images/Story line/5.png"
    ];
    
    override public function create():Void {
        super.create();

        FlxG.camera.bgColor = FlxColor.BLACK;

        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;

        FlxG.sound.playMusic("assets/music/Cry For Me The Weeknd.mp3", 0.8, true);

        promptText = new FlxText(0, GameConfig.SCREEN_H - 80, GameConfig.SCREEN_W, "Press SPACE to continue...");
        promptText.setFormat(null, 24, FlxColor.YELLOW, "center");
        promptText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
        promptText.scrollFactor.set(0, 0);
        add(promptText);

        loadCurrentImage();
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (canAdvance && FlxG.keys.justPressed.SPACE) {
            advanceToNext();
        }
    }
    
	function loadCurrentImage():Void
	{
        if (currentSprite != null) {
            remove(currentSprite);
            currentSprite.destroy();
        }

        currentSprite = new FlxSprite();
        currentSprite.loadGraphic(imagePaths[currentImageIndex]);
        currentSprite.scrollFactor.set(0, 0);

        var scaleX = GameConfig.SCREEN_W / currentSprite.width;
        var scaleY = GameConfig.SCREEN_H / currentSprite.height;
		var scale = Math.min(scaleX, scaleY);
        
        currentSprite.scale.set(scale, scale);
        currentSprite.updateHitbox();

        currentSprite.x = (GameConfig.SCREEN_W - currentSprite.width) / 2;
        currentSprite.y = (GameConfig.SCREEN_H - currentSprite.height) / 2;

        currentSprite.alpha = 1.0;
        add(currentSprite);

        members.remove(promptText);
        members.push(promptText);

        promptText.alpha = 0;
        FlxTween.tween(promptText, {alpha: 1}, 0.5, {
            startDelay: 1.0,
            ease: FlxEase.quadInOut
        });
    }
    
    function advanceToNext():Void {
        canAdvance = false;

        FlxTween.tween(currentSprite, {alpha: 0}, 0.5, {
            ease: FlxEase.quadInOut,
            onComplete: function(_) {
                currentImageIndex++;
                
				if (currentImageIndex < totalImages)
				{
                    loadCurrentImage();
                    canAdvance = true;
				}
				else
				{
                    transitionToSplash();
                }
            }
        });

        FlxTween.tween(promptText, {alpha: 0}, 0.3);
    }
    
	function transitionToSplash():Void
	{
        if (FlxG.sound.music != null) {
            FlxG.sound.music.stop();
        }

        FlxTween.tween(FlxG.camera, {alpha: 0}, 1.0, {
            ease: FlxEase.quadInOut,
			onComplete: function(_)
			{
                FlxG.switchState(SplashState.new);
            }
        });
    }
}
