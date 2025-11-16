package;

import core.GameConfig;
import flixel.FlxGame;
import openfl.display.Sprite;
import states.StorylineState;

class Main extends Sprite {
    public function new() {
        super();
		addChild(new FlxGame(GameConfig.SCREEN_W, GameConfig.SCREEN_H, StorylineState));
    }
}
