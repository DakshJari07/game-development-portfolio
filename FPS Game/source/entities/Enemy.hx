package entities;

import flixel.FlxG;
import flixel.FlxSprite;

class Enemy extends FlxSprite
{
    public var worldX:Float;
    public var worldY:Float;

	public var flash:Float = 0;
	public var fade:Float = 1;

	public var isAttacking:Bool = false;
	public var attackCooldown:Float = 0;
    public var deathAnimationComplete:Bool = false;
	public var hasDealtDamageThisAttack:Bool = false;
	private var hasPlayedShotSound:Bool = false;

    public var isAlive(get, set):Bool;
    inline function get_isAlive():Bool return alive;
    inline function set_isAlive(v:Bool):Bool { alive = v; return v; }

    static inline var FRAME_W:Int = 128;
    static inline var FRAME_H:Int = 128;

    var currentSheet:String = "";

    public function new(wx:Float, wy:Float)
    {
        super();
        worldX = wx;
        worldY = wy;

        scrollFactor.set(0, 0);

        alive = true;
        loadSheet("idle");
        animation.play("idle");

        origin.set(FRAME_W / 2, FRAME_H / 2);
    }

    inline function defineAnims(sheet:String):Void
    {
        animation.destroyAnimations();
        switch (sheet)
        {
			case "idle":
				animation.add("idle", [0, 1, 2, 3, 4, 5, 6], 8, true);
			case "shot":
				animation.add("shot", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], 12, false);
				trace("Defining shot animation with 12 frames at 12 FPS");
			case "dead":
                animation.add("dead", [0,1,2,3,4], 8, false);
        }
    }

    public function loadSheet(sheet:String):Void
    {
        if (currentSheet == sheet) return;
        currentSheet = sheet;

        switch (sheet)
        {
            case "idle":
				loadGraphic("assets/images/Idle.png", true, FRAME_W, FRAME_H);
			case "shot":
				loadGraphic("assets/images/Shot.png", true, FRAME_W, FRAME_H);
				trace("Loading Shot.png with 12 frames");
            case "dead":
                loadGraphic("assets/images/Dead.png", true, FRAME_W, FRAME_H);
        }

        defineAnims(sheet);
        updateHitbox();

        origin.set(FRAME_W, FRAME_H);
    }

    public function updateAnimationState(moving:Bool):Void
    {
        if (!alive)
        {
            loadSheet("dead");
            if (animation.name != "dead") animation.play("dead", true);
            return;
        }

		if (isAttacking)
		{
			loadSheet("shot");
			if (animation.name != "shot")
				animation.play("shot", true);
			return;
		}

		loadSheet("idle");
		if (animation.name != "idle")
			animation.play("idle");
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

		if (attackCooldown > 0)
			attackCooldown -= elapsed;

		if (isAttacking && animation.name == "shot" && animation.frameIndex == 7 && !hasPlayedShotSound)
		{
			try
			{
				var sound = FlxG.sound.play("assets/sounds/gun-shot-close.mp3");
				if (sound != null)
					sound.volume = 0.5;
			}
			catch (e:Dynamic) {}
			hasPlayedShotSound = true;
		}

		if (isAttacking && animation.finished)
		{
			isAttacking = false;
		}

        if (!alive && !deathAnimationComplete && animation.finished)
            deathAnimationComplete = true;
	}
	public function startAttack():Void
	{
		if (!alive || isAttacking || attackCooldown > 0)
			return;

		isAttacking = true;
		hasDealtDamageThisAttack = true;
		hasPlayedShotSound = false;
		attackCooldown = 4.0;
	}


    public function takeDamage():Void
    {
        if (!alive) return;

        alive = false;

        flash = 1.0;
        fade  = 1.0;

		isAttacking = false;
		hasDealtDamageThisAttack = false;
        
        loadSheet("dead");
        animation.play("dead", true);
        deathAnimationComplete = false;
    }
}
