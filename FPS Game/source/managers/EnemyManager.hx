package managers;

import Assets;
import Math;
import core.GameConfig;
import core.LevelData;
import entities.Enemy;
import flixel.FlxG;
class EnemyManager {
    public var list:Array<Enemy>;

    public function new() list = [];

    public function loadFromMap(map:Array<String>, minEnemies:Int = 5):Void {
        list = [];
        var positions = [];

		var validPositions = [];
		for (y in 0...map.length)
		{
			for (x in 0...map[y].length)
			{
				if (!LevelData.isWall(x, y) && isValidEmptySpace(map, x, y))
				{
					validPositions.push({x: x + 0.5, y: y + 0.5});
				}
			}
		}

		for (y in 0...map.length)
			for (x in 0...map[y].length)
				if (map[y].charAt(x) == 'E' && !LevelData.isWall(x, y))
                    positions.push({ x:x + 0.5, y:y + 0.5 });

		var attempts = 0;
		while (positions.length < minEnemies && attempts < 1000)
		{
			attempts++;
			if (validPositions.length > 0)
			{
				var randomPos = validPositions[Std.random(validPositions.length)];
				var tooClose = false;
				for (existing in positions)
				{
					var dx = randomPos.x - existing.x;
					var dy = randomPos.y - existing.y;
					var dist = Math.sqrt(dx * dx + dy * dy);
					if (dist < 2.0)
					{
						tooClose = true;
						break;
					}
				}
				if (!tooClose)
				{
					positions.push(randomPos);
				}
			}
        }

        for (p in positions)
            list.push(new Enemy(p.x, p.y));
    }

	function isValidEmptySpace(map:Array<String>, x:Int, y:Int):Bool
	{
		if (x < 1 || y < 1 || x >= map[0].length - 1 || y >= map.length - 1)
		{
			return false;
		}

		if (LevelData.isWall(x, y))
		{
			return false;
		}

		for (dy in -1...2)
		{
			for (dx in -1...2)
			{
				if (LevelData.isWall(x + dx, y + dy))
				{
					return false;
				}
			}
		}

		return true;
	}

	public function update(elapsed:Float, px:Float, py:Float):Float
	{
        var time = FlxG.game.ticks / 60.0;
		var totalDamage:Float = 0;
        
        for (e in list) {
            if (!e.alive && e.fade <= 0) continue;

			var dx = px - e.worldX;
			var dy = py - e.worldY;
            var dist = Math.sqrt(dx * dx + dy * dy);

			var attackRange = 10.0;
			if (e.alive && dist <= attackRange)
			{
				if (hasLineOfSight(e.worldX, e.worldY, px, py))
				{
					e.startAttack();
				}
			}

			var moved = false;

			e.updateAnimationState(moved);

			if (e.flash > 0)
				e.flash -= elapsed * 2;
            if (!e.alive && e.fade > 0) e.fade -= elapsed * 0.8;
			if (e.fade < 0)
				e.fade = 0;
			if (!e.isAttacking && e.hasDealtDamageThisAttack)
			{
				totalDamage += 20.0;
				e.hasDealtDamageThisAttack = false;
			}
		}
		return totalDamage;
    }

    public function hitEnemy(index:Int):Void {
        if (index < 0 || index >= list.length) return;
        var e = list[index];
        if (!e.alive) return;

		e.takeDamage();
        e.flash = 1.0;
        e.fade = 1.0;
        
		try
		{
			var sound = FlxG.sound.play("assets/sounds/grunt1-68324.mp3");
			if (sound != null)
				sound.volume = 0.9;
		}
		catch (e:Dynamic) {}
    }

    public function living():Int {
        var n = 0;
        for (e in list) if (e.alive) n++;
        return n;
	}
	function hasLineOfSight(x0:Float, y0:Float, x1:Float, y1:Float):Bool
	{
		var dx = x1 - x0;
		var dy = y1 - y0;
		var steps = Std.int(Math.max(Math.abs(dx), Math.abs(dy)) * 20);
		if (steps < 1)
			steps = 1;
		var sx = dx / steps;
		var sy = dy / steps;
		var x = x0;
		var y = y0;
		for (i in 0...steps)
		{
			x += sx;
			y += sy;
			if (LevelData.isWall(Std.int(x), Std.int(y)))
				return false;
		}
		return true;
	}
}

