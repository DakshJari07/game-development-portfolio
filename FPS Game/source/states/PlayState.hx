package states;

import Assets;
import core.GameConfig;
import core.LevelData;
import core.MouseLock;
import core.Raycaster;
import entities.BulletLightBlaster;
import entities.Player;
import entities.WeaponLightBlaster;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import managers.EnemyManager;
import openfl.Lib;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import ui.HUD;
import ui.MiniMap;

class PlayState extends FlxState {
    var rc:Raycaster;
    var pl:Player;
    var em:EnemyManager;
    var hud:HUD;
    var crosshair:FlxSprite;
	var mini:MiniMap;

    var weapon:WeaponLightBlaster;
    var bullets:Array<BulletLightBlaster> = [];

	var health:Int = 100;
	var previousHealth:Int = 100;
    var timeLeft:Float = GameConfig.TIMER_START;
	var gameOver:Bool = false;
    var overlay:FlxText;
	var startPrompt:FlxText;
	var gameStarted:Bool = false;
	var startScreenBullets:Array<BulletLightBlaster> = [];

	var endScreenSprite:FlxSprite;
	var endScreenPrompt:FlxText;
	var showingEndScreen:Bool = false;
	var endScreenType:String = "";
	var endScreenDelayTimer:Float = 0;
	var waitingForEndScreen:Bool = false;
	var pendingEndScreenMessage:String = "";

	var camBobTimer:Float = 0;
	var damageOverlay:FlxSprite;

    override public function create():Void {
        super.create();

        Assets.loadLightBlasterAssets();

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		try
		{
			FlxG.sound.playMusic("assets/music/bgm.mp3", 0.5, true);
		}
		catch (e:Dynamic)
		{
			trace("Could not load gameplay music: " + e);
		}

        FlxG.mouse.visible = false;
		FlxG.mouse.useSystemCursor = false;

        MouseLock.enable();
        MouseLock.installMouseMove();

        var map = LevelData.pickRandom();
        var px = 1.5;
        var py = 1.5;
        var pa = 0.0;

        for (j in 0...map.length)
            for (i in 0...map[0].length)
                if (map[j].charAt(i) == 'P') {
                    px = i + 0.5;
                    py = j + 0.5;
                }

        pl = new Player(px, py, pa);
        rc = new Raycaster(map);
        add(rc);
		rc.visible = false;

        em = new EnemyManager();
        em.loadFromMap(map, GameConfig.MIN_ENEMIES);

		for (enemy in em.list)
		{
			add(enemy);
			enemy.visible = false;
		}

        hud = new HUD();
        add(hud);
		hud.visible = false;

        crosshair = new FlxSprite();
        
		if (Assets.crosshairGraphic != null)
		{
            crosshair.loadGraphic(Assets.crosshairGraphic);
			crosshair.scale.set(2.0, 2.0);
            crosshair.x = (GameConfig.SCREEN_W - crosshair.width) / 2;
			crosshair.y = (GameConfig.SCREEN_H - crosshair.height) / 2 + 10;
		}
		else
		{
            crosshair.makeGraphic(4, 4, 0xffffffff);
            crosshair.x = (GameConfig.SCREEN_W - crosshair.width) / 2;
			crosshair.y = (GameConfig.SCREEN_H - crosshair.height) / 2 + 10;
        }
        
		crosshair.scrollFactor.set(0, 0);
		crosshair.cameras = [FlxG.camera];
        add(crosshair);
		crosshair.visible = false;

        overlay = new FlxText(0, GameConfig.SCREEN_H / 2 - 40, GameConfig.SCREEN_W, "");
        overlay.setFormat(null, 28, 0xffffffff, "center");
        overlay.scrollFactor.set(0, 0);
        overlay.alpha = 0;
		add(overlay);
		startPrompt = new FlxText(0, GameConfig.SCREEN_H / 2 - 20, GameConfig.SCREEN_W, "LEFT CLICK TO START THE GAME");
		startPrompt.setFormat(null, 24, 0xff00ff00, "center");
		startPrompt.setBorderStyle(OUTLINE, 0xff000000, 2);
		startPrompt.scrollFactor.set(0, 0);
		add(startPrompt);

        mini = new MiniMap(map, 140, 4);
        add(mini);
		mini.visible = false;

		damageOverlay = new FlxSprite(0, 0);
		damageOverlay.makeGraphic(GameConfig.SCREEN_W, GameConfig.SCREEN_H, 0xFFFF0000);
		damageOverlay.scrollFactor.set(0, 0);
		damageOverlay.alpha = 0;
		add(damageOverlay);

        weapon = new WeaponLightBlaster(
		GameConfig.SCREEN_W / 2 + 100, GameConfig.SCREEN_H - 325
        );
        add(weapon);
		weapon.visible = false;

        Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }

    override public function destroy():Void {
        super.destroy();
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }

    function onKeyDown(e:KeyboardEvent):Void {
		if (e.keyCode == 82)
		{
            if (!gameOver && weapon != null) {
                weapon.reload();
            } else {
				e.preventDefault();
                FlxG.resetState();
            }
        }
		if (e.keyCode == 77)
		{
			if (gameOver)
			{
				e.preventDefault();
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.stop();
				}
				MouseLock.disable();
				FlxG.mouse.visible = true;
				FlxG.mouse.useSystemCursor = true;
				FlxG.switchState(MenuState.new);
			}
		}
    }

	function onMouseDown(_):Void
	{
		if (waitingForEndScreen || showingEndScreen)
			return;

		if (!gameStarted)
		{
			gameStarted = true;
			if (startPrompt != null)
			{
				remove(startPrompt);
				startPrompt = null;
			}
			rc.visible = true;
			hud.visible = true;
			crosshair.visible = true;
			mini.visible = true;
			weapon.visible = true;

			for (enemy in em.list)
			{
				enemy.visible = true;
			}
			
			return;
		}
		shoot();
	}

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

		if (waitingForEndScreen)
		{
			endScreenDelayTimer += elapsed;
			if (endScreenDelayTimer >= 3.0)
			{
				waitingForEndScreen = false;
				displayEndScreenWithTransition(endScreenType, pendingEndScreenMessage);
			}
			return;
		}

		if (showingEndScreen)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (endScreenSprite != null)
				{
					remove(endScreenSprite);
					endScreenSprite = null;
				}
				if (endScreenPrompt != null)
				{
					remove(endScreenPrompt);
					endScreenPrompt = null;
				}
				showingEndScreen = false;
				gameOver = true;

				if (endScreenType == "loss")
				{
					try
					{
						var sound = FlxG.sound.play("assets/sounds/game_over.mp3");
						if (sound != null)
							sound.volume = 0.6;
					}
					catch (e:Dynamic) {}
				}
				else if (endScreenType == "win")
				{
					try
					{
						var sound = FlxG.sound.play("assets/sounds/you_won.mp3");
						if (sound != null)
							sound.volume = 0.7;
					}
					catch (e:Dynamic) {}
				}
			}
			return;
		}

		if (overlay.alpha < 1 && gameOver)
			overlay.alpha += elapsed * 1.5;
		if (gameOver && FlxG.keys.justPressed.M)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.stop();
			}
			MouseLock.disable();
			FlxG.mouse.visible = true;
			FlxG.mouse.useSystemCursor = true;
			FlxG.switchState(MenuState.new);
			return;
		}
        
		if (gameOver)
			return;
		if (!gameStarted)
			return;

        timeLeft -= elapsed;
        if (timeLeft <= 0) {
            timeLeft = 0;
			showEndScreen("loss", "TIME OVER\nPress R to restart\nPress M for Main Menu");
        }

        var mdx = MouseLock.getDX();
        pl.a += mdx * 0.0025;

		var isSprinting = FlxG.keys.pressed.SHIFT;
		var sprintMultiplier = isSprinting ? GameConfig.SPRINT_MULTIPLIER : 1.0;
		var spd = GameConfig.MOVE_SPEED * elapsed * sprintMultiplier;
        
        var mx = 0.0;
        var my = 0.0;
        if (FlxG.keys.pressed.W) { mx += Math.cos(pl.a) * spd; my += Math.sin(pl.a) * spd; }
        if (FlxG.keys.pressed.S) { mx -= Math.cos(pl.a) * spd; my -= Math.sin(pl.a) * spd; }
        if (FlxG.keys.pressed.A) { mx += Math.cos(pl.a - Math.PI / 2) * spd; my += Math.sin(pl.a - Math.PI / 2) * spd; }
        if (FlxG.keys.pressed.D) { mx += Math.cos(pl.a + Math.PI / 2) * spd; my += Math.sin(pl.a + Math.PI / 2) * spd; }

        tryMove(mx, my);

        var moving = (FlxG.keys.pressed.W || FlxG.keys.pressed.A || FlxG.keys.pressed.S || FlxG.keys.pressed.D);
		var bobSpeed = isSprinting ? 9 : 6;
		if (moving)
			camBobTimer += elapsed * bobSpeed;
		else
			camBobTimer *= 0.9;
        FlxG.camera.y = Math.sin(camBobTimer) * 3;
        FlxG.camera.x = Math.cos(camBobTimer * 0.5) * 2;

		var damage = em.update(elapsed, pl.x, pl.y);
		if (damage > 0)
		{
			previousHealth = health;
			health -= Std.int(Math.ceil(damage));
			if (health < 0)
				health = 0;
			if (previousHealth - health >= 20)
			{

				damageOverlay.alpha = 0.6;
				FlxTween.tween(damageOverlay, {alpha: 0}, 0.5);
			
				new FlxTimer().start(0.5, function(_)
				{
					try
					{
						var sound = FlxG.sound.play("assets/sounds/ouch.mp3");
						if (sound != null)
							sound.volume = 0.6;
					}
					catch (e:Dynamic) {}
				});
			}

			if (health <= 0 && !gameOver)
			{
				showEndScreen("loss", "YOU DIED\nPress R to restart\nPress M for Main Menu");
			}
		}

        if (!gameOver && em.living() == 0) {
			showEndScreen("win", "YOU WIN\nPress R to restart\nPress M for Main Menu");
        }

		rc.renderScene(pl.x, pl.y, pl.a, em.list);
		if (gameStarted)
		{
			updateEnemyBillboards(pl.x, pl.y, pl.a);

			var enemyInSight = pickEnemyInCrosshair();
			if (enemyInSight >= 0)
			{
				crosshair.color = 0xFF0000;
			}
			else
			{
				crosshair.color = 0xFFFFFF; 
			}
		}
        
        hud.updateHUD(health, em.living(), timeLeft, weapon.getAmmoString());
		mini.render(pl.x, pl.y, pl.a, em.list);

        var i = bullets.length;
        while (i-- > 0) {
            if (!bullets[i].alive) {
                bullets.splice(i, 1);
            }
		}
		var j = startScreenBullets.length;
		while (j-- > 0)
		{
			if (!startScreenBullets[j].alive)
			{
				startScreenBullets.splice(j, 1);
			}
		}
    }

    function tryMove(dx:Float, dy:Float):Void {
        var nx = pl.x + dx;
		var ny = pl.y + dy;
		var canMoveX = !LevelData.isWall(Std.int(nx), Std.int(pl.y));
		var canMoveY = !LevelData.isWall(Std.int(pl.x), Std.int(ny));

		if (canMoveX)
			canMoveX = !checkEnemyCollision(nx, pl.y);
		if (canMoveY)
			canMoveY = !checkEnemyCollision(pl.x, ny);

		if (canMoveX)
			pl.x = nx;
		if (canMoveY)
			pl.y = ny;
	}

	function checkEnemyCollision(px:Float, py:Float):Bool
	{
		var playerRadius = 0.3;
		var enemyRadius = 0.4;

		for (enemy in em.list)
		{
			if (!enemy.alive)
				continue;

			var dx = px - enemy.worldX;
			var dy = py - enemy.worldY;
			var dist = Math.sqrt(dx * dx + dy * dy);

			if (dist < playerRadius + enemyRadius)
			{
				return true;
			}
		}

		return false;
    }

    function shoot():Void {
        if (gameOver) return;

		var newBullets = weapon.fire();
		if (newBullets.length > 0)
		{
			for (bullet in newBullets)
			{
				bullets.push(bullet);
				add(bullet);
			}

			try
			{
				var sound = FlxG.sound.play("assets/sounds/lmg_fire01.mp3");
				if (sound != null)
					sound.volume = 0.4;
			}
			catch (e:Dynamic)
			{
				trace("Error playing fire sound: " + e);
			}

			var idx = pickEnemyInCrosshair();
			if (idx >= 0)
			{
				em.hitEnemy(idx);
				rc.flash = 0.25;
			}
		}

    }

    function pickEnemyInCrosshair():Int {
		var baseCone:Float = 0.05;
        var hit = -1;
        var minDist = 999.0;
        var px = pl.x, py = pl.y, pa = pl.a;

        for (i in 0...em.list.length) {
            var e = em.list[i];
            if (!e.alive) continue;
		
			var headOffset = -0.2; 
			var targetX = e.worldX + headOffset;
			var targetY = e.worldY;

			var dx = targetX - px;
			var dy = targetY - py;
			var dist = Math.sqrt(dx * dx + dy * dy);
			var dynamicCone = baseCone;
			if (dist < 2.0)
			{
				dynamicCone = baseCone * 3.0;
			}
			else if (dist < 4.0)
			{
				dynamicCone = baseCone * 2.0;
			}
            
            var ang = Math.atan2(dy, dx) - pa;
            while (ang < -Math.PI) ang += 2 * Math.PI;
            while (ang > Math.PI) ang -= 2 * Math.PI;
			if (Math.abs(ang) < dynamicCone && dist < minDist && hasLineOfSight(px, py, targetX, targetY))
			{
                minDist = dist;
                hit = i;
            }
        }
        return hit;
    }

    function hasLineOfSight(x0:Float, y0:Float, x1:Float, y1:Float):Bool {
        var dx = x1 - x0;
        var dy = y1 - y0;
		var dist = Math.sqrt(dx * dx + dy * dy);

		var steps = Std.int(dist * 40);
		if (steps < 5)
			steps = 5;
        
        var sx = dx / steps;
        var sy = dy / steps;
        var x = x0;
        var y = y0;

        for (i in 0...steps) {
            x += sx;
            y += sy;
			var gridX = Std.int(x);
			var gridY = Std.int(y);

			if (LevelData.isWall(gridX, gridY))
				return false;

			var fractX = x - gridX;
			var fractY = y - gridY;

			if (fractX < 0.1 && LevelData.isWall(gridX - 1, gridY))
				return false;
			if (fractX > 0.9 && LevelData.isWall(gridX + 1, gridY))
				return false;
			if (fractY < 0.1 && LevelData.isWall(gridX, gridY - 1))
				return false;
			if (fractY > 0.9 && LevelData.isWall(gridX, gridY + 1))
				return false;
			
			if (fractX < 0.1 && fractY < 0.1 && LevelData.isWall(gridX - 1, gridY - 1))
				return false;
			if (fractX > 0.9 && fractY < 0.1 && LevelData.isWall(gridX + 1, gridY - 1))
				return false;
			if (fractX < 0.1 && fractY > 0.9 && LevelData.isWall(gridX - 1, gridY + 1))
				return false;
			if (fractX > 0.9 && fractY > 0.9 && LevelData.isWall(gridX + 1, gridY + 1))
				return false;
        }

        return true;
    }

	function updateEnemyBillboards(px:Float, py:Float, pa:Float):Void
	{
		var W = GameConfig.SCREEN_W;
		var H = GameConfig.SCREEN_H;
		var halfFov = GameConfig.FOV / 2;

		for (e in em.list)
		{
			var dx = e.worldX - px;
			var dy = e.worldY - py;
			var dist = Math.sqrt(dx * dx + dy * dy);

			var angle = Math.atan2(dy, dx) - pa;

			while (angle < -Math.PI)
				angle += 2 * Math.PI;
			while (angle > Math.PI)
				angle -= 2 * Math.PI;

			if (angle < -halfFov || angle > halfFov)
			{
				e.visible = false;
				continue;
			}

			if (!hasLineOfSight(px, py, e.worldX, e.worldY))
			{
				e.visible = false;
				continue;
			}

			var maxScale = 2.5;
			var minScale = 0.8;
			var maxDistance = 10.0;
		
			var dist_quarter = maxDistance / 4.0;
			var dist_third = maxDistance / 3.0;
			var dist_half = maxDistance / 2.0;
			var dist_max = maxDistance;
			var dist_max_plus_half = maxDistance * 1.5;
			var dist_max_plus_full = maxDistance * 2.0;
		
			var scale_at_quarter = maxScale;
			var scale_at_third = 2.5;
			var scale_at_half = 1.5;
			var scale_at_max = 1.0;
			var scale_at_max_plus_half = 0.8;

		var scale:Float;
		if (dist <= dist_quarter)
			{
			scale = maxScale;
		}
		else if (dist <= dist_third)
			{
			var progress = (dist - dist_quarter) / (dist_third - dist_quarter);
			scale = maxScale - (maxScale - scale_at_third) * progress;
		}
		else if (dist <= dist_half)
			{
			var progress = (dist - dist_third) / (dist_half - dist_third);
			scale = scale_at_third - (scale_at_third - scale_at_half) * progress;
		}
		else if (dist <= dist_max)
			{
			var progress = (dist - dist_half) / (dist_max - dist_half);
			scale = scale_at_half - (scale_at_half - scale_at_max) * progress;
		}
		else if (dist <= dist_max_plus_half)
			{
			var progress = (dist - dist_max) / (dist_max_plus_half - dist_max);
			scale = scale_at_max - (scale_at_max - scale_at_max_plus_half) * progress;
		}
		else if (dist <= dist_max_plus_full)
			{
			var progress = (dist - dist_max_plus_half) / (dist_max_plus_full - dist_max_plus_half);
			scale = scale_at_max_plus_half - (scale_at_max_plus_half - minScale) * progress;
		}
		else
			{
			scale = minScale;
		}

		if (scale < minScale)
			scale = minScale;
		if (scale > maxScale)
			scale = maxScale;

			e.scale.set(scale, scale);

			e.x = (angle + halfFov) / GameConfig.FOV * W;
			var verticalOffset = 50.0;
			e.y = H / 2 - verticalOffset;

			if (e.flash > 0)
			{
				e.alpha = 1.0;
				e.color = 0xFFFFFF;
			}
			else if (!e.alive)
			{
				e.alpha = e.fade;
				e.color = 0xFFFFFF;
			}
			else
			{
				e.alpha = 1.0;
				e.color = 0xFFFFFF;
			}

			e.visible = true;
		}
	}

	private function showEndScreen(type:String, overlayMessage:String):Void
	{
		waitingForEndScreen = true;
		endScreenDelayTimer = 0;
		endScreenType = type;
		pendingEndScreenMessage = overlayMessage;
		overlay.text = overlayMessage;
	}

	private function displayEndScreenWithTransition(type:String, overlayMessage:String):Void
	{
		showingEndScreen = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		weapon.visible = false;
		mini.visible = false;
		crosshair.visible = false;
		hud.visible = false;

		endScreenSprite = new FlxSprite(0, 0);

		if (type == "loss")
		{
			endScreenSprite.loadGraphic("assets/images/Story line/6.png");
			try
			{
				var sound = FlxG.sound.play("assets/sounds/sad.mp3");
				if (sound != null)
					sound.volume = 0.6;
			}
			catch (e:Dynamic) {}
		}
		else if (type == "win")
		{
			endScreenSprite.loadGraphic("assets/images/Story line/7.png");
			try
			{
				var sound = FlxG.sound.play("assets/sounds/cong.mp3");
				if (sound != null)
					sound.volume = 0.7;
			}
			catch (e:Dynamic) {}
		}

		endScreenSprite.setGraphicSize(GameConfig.SCREEN_W, GameConfig.SCREEN_H);
		endScreenSprite.updateHitbox();
		endScreenSprite.scrollFactor.set(0, 0);

		endScreenSprite.alpha = 0;
		add(endScreenSprite);

		endScreenPrompt = new FlxText(0, GameConfig.SCREEN_H - 80, GameConfig.SCREEN_W, "Press SPACE to continue...");
		endScreenPrompt.setFormat(null, 24, FlxColor.YELLOW, "center");
		endScreenPrompt.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
		endScreenPrompt.scrollFactor.set(0, 0);
		endScreenPrompt.alpha = 0;
		add(endScreenPrompt);

		FlxTween.tween(endScreenSprite, {alpha: 1}, 0.5);
		FlxTween.tween(endScreenPrompt, {alpha: 1}, 0.5, {startDelay: 0.5});
	}
}
