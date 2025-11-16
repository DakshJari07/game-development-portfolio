package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
    // Game constants
    private static inline var BUBBLE_SIZE:Int = 32;
    private static inline var GRID_WIDTH:Int = 15;
    private static inline var GRID_HEIGHT:Int = 20;
    private static inline var SHOOTER_Y:Int = 550;
    private static inline var BUBBLE_SPEED:Float = 400;
    private static inline var GRID_OFFSET_X:Int = 175; // Center the grid horizontally
    
    // Bubble colors - More vibrant and appealing
    private static var BUBBLE_COLORS:Array<FlxColor> = [
        FlxColor.fromRGB(255, 100, 100), // Bright red
        FlxColor.fromRGB(100, 150, 255), // Bright blue  
        FlxColor.fromRGB(100, 255, 100), // Bright green
        FlxColor.fromRGB(255, 255, 100), // Bright yellow
        FlxColor.fromRGB(255, 100, 255), // Bright magenta
        FlxColor.fromRGB(100, 255, 255), // Bright cyan
        FlxColor.fromRGB(255, 180, 100)  // Bright orange
    ];
    
    // Game objects
    private var bubbleGrid:Array<Array<Bubble>>;
    public var activeBubbles:FlxGroup; // Made public for Bubble class access
    private var shooter:Shooter;
    private var currentBubble:Bubble;
    private var trajectory:FlxSprite;
    private var gameOver:Bool = false;
    
    // Shooting mechanics
    private var aimAngle:Float = 0;
    private var shootingBubble:Bubble;
    private var isAiming:Bool = true;
    private var shotCount:Int = 0;
    private var shotsUntilDrop:Int = 5; // Bubbles drop every 5 shots
    
    override public function create():Void
    {
        super.create();
        
        // Create beautiful gradient background
        createGradientBackground();
        
        // Initialize game objects
        activeBubbles = new FlxGroup();
        add(activeBubbles);
        
        // Initialize bubble grid
        initializeBubbleGrid();
        
        // Create enhanced shooter - centered
        shooter = new Shooter(FlxG.width / 2 - 25, SHOOTER_Y);
        add(shooter);
        
        // Create enhanced trajectory line
        trajectory = new FlxSprite();
        trajectory.makeGraphic(6, 250, FlxColor.WHITE);
        trajectory.alpha = 0.8;
        trajectory.blend = openfl.display.BlendMode.ADD; // Glowing effect
        add(trajectory);
        
        // Create first bubble to shoot
        createNextBubble();
        
        // Fill initial bubble pattern
        fillInitialBubbles();
        
        // Add UI elements
        createUI();
    }
    
    private function createGradientBackground():Void
    {
        // Create a beautiful gradient background
        var bg = new FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
        
        // Draw gradient from dark blue at top to lighter blue at bottom
        for (y in 0...FlxG.height)
        {
            var ratio = y / FlxG.height;
            var topColor = FlxColor.fromRGB(15, 25, 50);    // Dark blue-purple
            var bottomColor = FlxColor.fromRGB(30, 50, 90); // Lighter blue
            
            // Interpolate between colors
            var r = Std.int(topColor.red + (bottomColor.red - topColor.red) * ratio);
            var g = Std.int(topColor.green + (bottomColor.green - topColor.green) * ratio);
            var b = Std.int(topColor.blue + (bottomColor.blue - topColor.blue) * ratio);
            
            var lineColor = FlxColor.fromRGB(r, g, b);
            
            for (x in 0...FlxG.width)
            {
                bg.pixels.setPixel32(x, y, lineColor);
            }
        }
        
        add(bg);
    }
    
    private function createUI():Void
    {
        // You can add score, shot counter, etc. here later
        // For now, just some decorative elements
        
        // Add some stars for atmosphere
        for (i in 0...20)
        {
            var star = new FlxSprite();
            star.makeGraphic(3, 3, FlxColor.WHITE);
            star.x = Math.random() * FlxG.width;
            star.y = Math.random() * (FlxG.height * 0.3); // Only in top 30%
            star.alpha = 0.3 + Math.random() * 0.7;
            add(star);
        }
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        if (gameOver) return;
        
        handleInput();
        updateTrajectory();
        checkGameOver();
    }
    
    private function initializeBubbleGrid():Void
    {
        bubbleGrid = new Array<Array<Bubble>>();
        for (x in 0...GRID_WIDTH)
        {
            bubbleGrid[x] = new Array<Bubble>();
            for (y in 0...GRID_HEIGHT)
            {
                bubbleGrid[x][y] = null;
            }
        }
    }
    
    private function fillInitialBubbles():Void
    {
        // Fill first 8 rows with random colored bubbles in proper hexagonal pattern
        for (y in 0...8)
        {
            // Calculate how many bubbles fit in this row
            var bubblesInRow = GRID_WIDTH - (y % 2); // Odd rows have one less bubble
            var startOffset = (y % 2) * 0.5; // Offset odd rows by half a bubble
            
            for (x in 0...bubblesInRow)
            {
                var color = BUBBLE_COLORS[Std.int(Math.random() * BUBBLE_COLORS.length)];
                createBubbleAt(x, y, color);
            }
        }
    }
    
    private function createBubbleAt(gridX:Int, gridY:Int, color:FlxColor):Bubble
    {
        var bubble = new Bubble();
        bubble.setColor(color);
        bubble.gridX = gridX;
        bubble.gridY = gridY;
        
        // Calculate screen position for hexagonal grid - CENTERED
        var screenX = GRID_OFFSET_X + (gridX * BUBBLE_SIZE) + ((gridY % 2) * (BUBBLE_SIZE / 2));
        var screenY = 50 + (gridY * (BUBBLE_SIZE * 0.75));
        
        bubble.x = screenX;
        bubble.y = screenY;
        
        bubbleGrid[gridX][gridY] = bubble;
        activeBubbles.add(bubble);
        
        return bubble;
    }
    
    private function createNextBubble():Void
    {
        currentBubble = new Bubble();
        var color = BUBBLE_COLORS[Std.int(Math.random() * BUBBLE_COLORS.length)];
        currentBubble.setColor(color);
        currentBubble.x = shooter.x + 16; // Center on shooter barrel (adjusted for new shooter)
        currentBubble.y = shooter.y - BUBBLE_SIZE + 5;
        add(currentBubble);
        isAiming = true;
    }
    
    private function handleInput():Void
    {
        if (!isAiming) return;
        
        // Mouse aiming - calculate angle manually
        var mouseX = FlxG.mouse.x;
        var mouseY = FlxG.mouse.y;
        var deltaX = mouseX - shooter.x;
        var deltaY = mouseY - shooter.y;
        aimAngle = Math.atan2(deltaY, deltaX) * 180 / Math.PI;
        
        // Clamp angle to prevent shooting backwards
        aimAngle = FlxMath.bound(aimAngle, -160, -20);
        
        // Shoot on click
        if (FlxG.mouse.justPressed)
        {
            shootBubble();
        }
    }
    
    private function updateTrajectory():Void
    {
        if (!isAiming) 
        {
            trajectory.visible = false;
            return;
        }
        
        trajectory.visible = true;
        trajectory.x = shooter.x + 20; // Center on shooter barrel (adjusted for new shooter size)
        trajectory.y = shooter.y - 10;
        trajectory.angle = aimAngle + 90;
        
        // Update shooter barrel rotation
        shooter.updateAim(aimAngle);
        
        // Add pulsing effect to trajectory
        trajectory.alpha = 0.6 + 0.3 * Math.sin(FlxG.game.ticks * 0.1);
    }
    
    private function shootBubble():Void
    {
        if (!isAiming) return;
        
        isAiming = false;
        shootingBubble = currentBubble;
        
        // Calculate velocity using angle
        var radians = aimAngle * Math.PI / 180;
        shootingBubble.velocity.x = Math.cos(radians) * BUBBLE_SPEED;
        shootingBubble.velocity.y = Math.sin(radians) * BUBBLE_SPEED;
        
        // Set up collision detection
        shootingBubble.onCollision = onBubbleCollision;
        shootingBubble.isShooting = true;
    }
    
    private function onBubbleCollision(bubble:Bubble):Void
    {
        if (bubble != shootingBubble) return;
        
        // Stop the bubble
        bubble.velocity.set(0, 0);
        bubble.isShooting = false;
        
        // Find closest grid position
        var gridPos = findClosestGridPosition(bubble);
        
        if (gridPos != null && gridPos.x >= 0 && gridPos.y >= 0 && 
            gridPos.x < GRID_WIDTH && gridPos.y < GRID_HEIGHT &&
            bubbleGrid[Std.int(gridPos.x)][Std.int(gridPos.y)] == null)
        {
            // Place bubble in grid
            var gx = Std.int(gridPos.x);
            var gy = Std.int(gridPos.y);
            bubble.gridX = gx;
            bubble.gridY = gy;
            bubbleGrid[gx][gy] = bubble;
            activeBubbles.add(bubble);
            
            // Position bubble exactly on grid using same formula as createBubbleAt - CENTERED
            var screenX = GRID_OFFSET_X + (gx * BUBBLE_SIZE) + ((gy % 2) * (BUBBLE_SIZE / 2));
            var screenY = 50 + (gy * (BUBBLE_SIZE * 0.75));
            bubble.x = screenX;
            bubble.y = screenY;
            
            // Check for matches - MUST be 3 or more to clear
            var matches = findMatches(gx, gy, bubble.bubbleColor);
            if (matches.length >= 3)
            {
                trace("Match found! " + matches.length + " bubbles");
                // Remove matching bubbles
                for (match in matches)
                {
                    bubbleGrid[match.gridX][match.gridY] = null;
                    activeBubbles.remove(match);
                    match.destroy();
                }
                
                // Check for floating bubbles
                removeFloatingBubbles();
            }
            else
            {
                trace("No match - only " + matches.length + " bubbles");
            }
            
            // Increment shot count and check if bubbles should drop
            shotCount++;
            if (shotCount >= shotsUntilDrop)
            {
                shotCount = 0;
                dropBubblesDown();
            }
            
            // Create next bubble after a short delay
            new FlxTimer().start(0.3, function(timer:FlxTimer) {
                createNextBubble();
            });
        }
        else
        {
            // Collision failed, remove bubble and create new one
            bubble.destroy();
            createNextBubble();
        }
        
        // Clean up FlxPoint
        if (gridPos != null) gridPos.put();
    }
    
    private function findClosestGridPosition(bubble:Bubble):FlxPoint
    {
        var bestDistance = Math.POSITIVE_INFINITY;
        var bestPos:FlxPoint = null;
        
        for (y in 0...GRID_HEIGHT)
        {
            for (x in 0...GRID_WIDTH)
            {
                if (bubbleGrid[x][y] != null) continue;
                
                // Check if position has support (connected to existing bubbles)
                if (!hasSupport(x, y)) continue;
                
                // Calculate screen position using same formula as createBubbleAt - CENTERED
                var screenX = GRID_OFFSET_X + (x * BUBBLE_SIZE) + ((y % 2) * (BUBBLE_SIZE / 2));
                var screenY = 50 + (y * (BUBBLE_SIZE * 0.75));
                
                var distance = Math.sqrt(Math.pow(bubble.x - screenX, 2) + Math.pow(bubble.y - screenY, 2));
                
                if (distance < bestDistance && distance < BUBBLE_SIZE * 1.5)
                {
                    bestDistance = distance;
                    if (bestPos != null) bestPos.put(); // Clean up previous point
                    bestPos = FlxPoint.get(x, y);
                }
            }
        }
        
        trace("Best position found: " + (bestPos != null ? bestPos.x + "," + bestPos.y : "null") + " distance: " + bestDistance);
        
        return bestPos;
    }
    
    private function hasSupport(x:Int, y:Int):Bool
    {
        // Top row is always supported
        if (y == 0) return true;
        
        // Check adjacent positions for existing bubbles
        var neighbors = getNeighbors(x, y);
        for (neighbor in neighbors)
        {
            var nx = Std.int(neighbor.x);
            var ny = Std.int(neighbor.y);
            if (bubbleGrid[nx][ny] != null)
            {
                // Clean up neighbor points
                for (n in neighbors) n.put();
                return true;
            }
        }
        
        // Clean up neighbor points
        for (n in neighbors) n.put();
        return false;
    }
    
    private function findMatches(startX:Int, startY:Int, color:FlxColor):Array<Bubble>
    {
        var matches = new Array<Bubble>();
        var visited = new Array<Array<Bool>>();
        
        // Initialize visited array
        for (x in 0...GRID_WIDTH)
        {
            visited[x] = new Array<Bool>();
            for (y in 0...GRID_HEIGHT)
                visited[x][y] = false;
        }
        
        // Flood fill to find connected bubbles of same color
        floodFill(startX, startY, color, matches, visited);
        
        return matches;
    }
    
    private function floodFill(x:Int, y:Int, color:FlxColor, matches:Array<Bubble>, visited:Array<Array<Bool>>):Void
    {
        // Bounds check
        if (x < 0 || x >= GRID_WIDTH || y < 0 || y >= GRID_HEIGHT) return;
        if (visited[x][y]) return;
        if (bubbleGrid[x][y] == null) return;
        if (bubbleGrid[x][y].bubbleColor != color) return;
        
        visited[x][y] = true;
        matches.push(bubbleGrid[x][y]);
        
        // Check all neighbors
        var neighbors = getNeighbors(x, y);
        for (neighbor in neighbors)
        {
            floodFill(Std.int(neighbor.x), Std.int(neighbor.y), color, matches, visited);
        }
        
        // Clean up neighbor points
        for (n in neighbors) n.put();
    }
    
    private function getNeighbors(x:Int, y:Int):Array<FlxPoint>
    {
        var neighbors = new Array<FlxPoint>();
        
        // Hexagonal grid neighbors depend on row parity
        if (y % 2 == 0) // Even row
        {
            neighbors.push(FlxPoint.get(x - 1, y - 1));
            neighbors.push(FlxPoint.get(x, y - 1));
            neighbors.push(FlxPoint.get(x - 1, y));
            neighbors.push(FlxPoint.get(x + 1, y));
            neighbors.push(FlxPoint.get(x - 1, y + 1));
            neighbors.push(FlxPoint.get(x, y + 1));
        }
        else // Odd row
        {
            neighbors.push(FlxPoint.get(x, y - 1));
            neighbors.push(FlxPoint.get(x + 1, y - 1));
            neighbors.push(FlxPoint.get(x - 1, y));
            neighbors.push(FlxPoint.get(x + 1, y));
            neighbors.push(FlxPoint.get(x, y + 1));
            neighbors.push(FlxPoint.get(x + 1, y + 1));
        }
        
        return neighbors.filter(function(p) {
            return p.x >= 0 && p.x < GRID_WIDTH && p.y >= 0 && p.y < GRID_HEIGHT;
        });
    }
    
    private function removeFloatingBubbles():Void
    {
        var connected = new Array<Array<Bool>>();
        
        // Initialize connected array
        for (x in 0...GRID_WIDTH)
        {
            connected[x] = new Array<Bool>();
            for (y in 0...GRID_HEIGHT)
                connected[x][y] = false;
        }
        
        // Mark all bubbles connected to top row
        for (x in 0...GRID_WIDTH)
        {
            if (bubbleGrid[x][0] != null)
                markConnected(x, 0, connected);
        }
        
        // Remove unconnected bubbles
        for (x in 0...GRID_WIDTH)
        {
            for (y in 0...GRID_HEIGHT)
            {
                if (bubbleGrid[x][y] != null && !connected[x][y])
                {
                    var bubble = bubbleGrid[x][y];
                    bubbleGrid[x][y] = null;
                    activeBubbles.remove(bubble);
                    bubble.destroy();
                }
            }
        }
    }
    
    private function markConnected(x:Int, y:Int, connected:Array<Array<Bool>>):Void
    {
        if (x < 0 || x >= GRID_WIDTH || y < 0 || y >= GRID_HEIGHT) return;
        if (connected[x][y]) return;
        if (bubbleGrid[x][y] == null) return;
        
        connected[x][y] = true;
        
        var neighbors = getNeighbors(x, y);
        for (neighbor in neighbors)
        {
            markConnected(Std.int(neighbor.x), Std.int(neighbor.y), connected);
        }
        
        // Clean up neighbor points
        for (n in neighbors) n.put();
    }
    
    private function dropBubblesDown():Void
    {
        trace("Dropping bubbles down!");
        
        // Move all bubbles down by one row
        // Start from bottom to avoid overwriting
        for (y in 0...(GRID_HEIGHT - 1))
        {
            var sourceRow = GRID_HEIGHT - 2 - y; // Start from second-to-bottom row
            var targetRow = sourceRow + 1; // Move to row below
            
            for (x in 0...GRID_WIDTH)
            {
                if (bubbleGrid[x][sourceRow] != null)
                {
                    // Move bubble down
                    var bubble = bubbleGrid[x][sourceRow];
                    bubbleGrid[x][sourceRow] = null;
                    bubbleGrid[x][targetRow] = bubble;
                    
                    // Update bubble's grid position
                    bubble.gridY = targetRow;
                    
                    // Update visual position - CENTERED
                    var screenX = GRID_OFFSET_X + (x * BUBBLE_SIZE) + ((targetRow % 2) * (BUBBLE_SIZE / 2));
                    var screenY = 50 + (targetRow * (BUBBLE_SIZE * 0.75));
                    bubble.x = screenX;
                    bubble.y = screenY;
                }
            }
        }
        
        // Add new row at top
        addNewTopRow();
        
        // Check if game over after dropping
        checkGameOver();
    }
    
    private function addNewTopRow():Void
    {
        // Add a new row of random bubbles at the top
        var bubblesInRow = GRID_WIDTH; // Top row (row 0) has full width
        
        for (x in 0...bubblesInRow)
        {
            // Only add bubble if there's space
            if (bubbleGrid[x][0] == null)
            {
                var color = BUBBLE_COLORS[Std.int(Math.random() * BUBBLE_COLORS.length)];
                createBubbleAt(x, 0, color);
            }
        }
    }
    
    private function checkGameOver():Void
    {
        // Check if bubbles reached bottom (game over)
        for (x in 0...GRID_WIDTH)
        {
            if (bubbleGrid[x][GRID_HEIGHT - 1] != null)
            {
                gameOver = true;
                trace("Game Over! Bubbles reached the bottom!");
                return;
            }
        }
        
        // Also check if bubbles are getting close to shooter (alternative game over)
        var dangerZone = GRID_HEIGHT - 3; // 3 rows from bottom
        for (x in 0...GRID_WIDTH)
        {
            if (bubbleGrid[x][dangerZone] != null)
            {
                trace("Warning! Bubbles approaching shooter!");
                // You could add visual warning here
            }
        }
        
        // Check if all bubbles cleared (win condition)
        var bubblesRemaining = false;
        for (x in 0...GRID_WIDTH)
        {
            for (y in 0...GRID_HEIGHT)
            {
                if (bubbleGrid[x][y] != null)
                {
                    bubblesRemaining = true;
                    break;
                }
            }
            if (bubblesRemaining) break;
        }
        
        if (!bubblesRemaining)
        {
            gameOver = true;
            trace("You Win! All bubbles cleared!");
        }
    }
}

class Bubble extends FlxSprite
{
    public var gridX:Int = -1;
    public var gridY:Int = -1;
    public var bubbleColor:FlxColor;
    public var isShooting:Bool = false;
    public var onCollision:Bubble->Void;
    
    public function new()
    {
        super();
        // Create a circular bubble using loadGraphic or drawing
        createBubbleGraphic();
    }
    
    private function createBubbleGraphic():Void
    {
        makeGraphic(32, 32, FlxColor.TRANSPARENT);
        
        var centerX = 16;
        var centerY = 16;
        var radius = 14;
        
        // Draw enhanced bubble with gradient and shine
        for (y in 0...32)
        {
            for (x in 0...32)
            {
                var dx = x - centerX;
                var dy = y - centerY;
                var distance = Math.sqrt(dx * dx + dy * dy);
                
                if (distance <= radius)
                {
                    if (distance <= radius - 2)
                    {
                        // Create gradient effect from light to dark
                        var gradientFactor = 1.0 - (distance / (radius - 2));
                        var brightness = Std.int(180 + (75 * gradientFactor));
                        brightness = Std.int(Math.min(255, brightness));
                        
                        // Add shine effect in top-left
                        var shineX = x - (centerX - 4);
                        var shineY = y - (centerY - 4);
                        var shineDist = Math.sqrt(shineX * shineX + shineY * shineY);
                        
                        if (shineDist < 4)
                        {
                            brightness = Std.int(Math.min(255, brightness + 40));
                        }
                        
                        var color = (0xFF << 24) | (brightness << 16) | (brightness << 8) | brightness;
                        pixels.setPixel32(x, y, color);
                    }
                    else if (distance <= radius - 1)
                    {
                        // Inner border - slightly darker
                        pixels.setPixel32(x, y, 0xFF999999);
                    }
                    else
                    {
                        // Outer border - dark
                        pixels.setPixel32(x, y, 0xFF333333);
                    }
                }
            }
        }
    }
    
    public function setColor(color:FlxColor):Void
    {
        bubbleColor = color;
        this.color = color;
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        if (isShooting)
        {
            // Bounce off walls
            if (x <= 0 || x >= FlxG.width - width)
            {
                velocity.x *= -1;
                x = FlxMath.bound(x, 0, FlxG.width - width);
            }
            
            // Check collision with other bubbles
            var playState = cast(FlxG.state, PlayState);
            playState.activeBubbles.forEachExists(function(basic:flixel.FlxBasic) {
                var other = cast(basic, Bubble);
                if (other != null && other != this && !other.isShooting)
                {
                    var distance = Math.sqrt(Math.pow(this.x - other.x, 2) + Math.pow(this.y - other.y, 2));
                    // Tighter collision detection - bubbles must be closer
                    if (distance < 28)
                    {
                        if (onCollision != null)
                            onCollision(this);
                    }
                }
            });
            
            // Stop at top of screen
            if (y <= 50)
            {
                if (onCollision != null)
                    onCollision(this);
            }
        }
    }
}

class Shooter extends FlxSprite
{
    private var barrel:FlxSprite;
    private var base:FlxSprite;
    private var currentAngle:Float = -90; // Default pointing up
    
    public function new(x:Float, y:Float)
    {
        super(x, y);
        createShooterGraphics();
    }
    
    private function createShooterGraphics():Void
    {
        // Create the base (cannon platform)
        makeGraphic(50, 30, FlxColor.TRANSPARENT);
        
        // Draw a nice rounded platform base
        var centerX = 25;
        var centerY = 15;
        
        for (py in 0...30)
        {
            for (px in 0...50)
            {
                var dx = px - centerX;
                var dy = py - centerY;
                
                // Create rounded platform shape
                var ovalDist = Math.sqrt((dx * dx / 625) + (dy * dy / 225));
                
                if (ovalDist <= 1.0)
                {
                    if (ovalDist <= 0.85)
                    {
                        // Main platform - metallic blue-gray gradient
                        var brightness = Std.int(100 + (70 * (1.0 - ovalDist)));
                        var color = FlxColor.fromRGB(brightness - 10, brightness, brightness + 20);
                        pixels.setPixel32(px, py, color);
                    }
                    else
                    {
                        // Platform edge - darker outline
                        pixels.setPixel32(px, py, FlxColor.fromRGB(40, 45, 60));
                    }
                }
            }
        }
        
        // Add platform highlights for 3D effect
        for (px in 10...40)
        {
            pixels.setPixel32(px, 8, FlxColor.fromRGB(180, 190, 220)); // Top highlight
        }
        
        // Create barrel as separate sprite for rotation
        barrel = new FlxSprite(x + 22, y - 20);
        barrel.makeGraphic(10, 40, FlxColor.TRANSPARENT);
        
        // Draw enhanced barrel with gradient and details
        for (py in 0...40)
        {
            for (px in 0...10)
            {
                // Barrel outline
                if (px == 0 || px == 9)
                {
                    barrel.pixels.setPixel32(px, py, FlxColor.fromRGB(30, 35, 45));
                }
                // Barrel body with metallic gradient
                else
                {
                    var centerDist = Math.abs(px - 4.5) / 4.5;
                    var brightness = Std.int(110 - (50 * centerDist));
                    
                    // Add some detail bands
                    if (py >= 2 && py <= 4)
                    {
                        brightness = Std.int(brightness * 0.7); // Dark band near tip
                    }
                    else if (py >= 35 && py <= 37)
                    {
                        brightness += 20; // Light band near base
                    }
                    
                    barrel.pixels.setPixel32(px, py, FlxColor.fromRGB(brightness - 5, brightness, brightness + 10));
                }
            }
        }
        
        // Add barrel tip detail
        for (px in 2...8)
        {
            barrel.pixels.setPixel32(px, 0, FlxColor.fromRGB(20, 25, 35)); // Dark tip
            barrel.pixels.setPixel32(px, 1, FlxColor.fromRGB(60, 70, 90)); // Highlight
        }
        
        barrel.origin.set(5, 35); // Set rotation point at base of barrel
    }
    
    public function updateAim(angle:Float):Void
    {
        currentAngle = angle;
        if (barrel != null)
        {
            barrel.angle = angle + 90; // Convert to barrel rotation
        }
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        if (barrel != null)
        {
            // Position barrel at center of base
            barrel.x = x + 20;
            barrel.y = y - 15;
        }
    }
    
    override public function draw():Void
    {
        super.draw();
        if (barrel != null)
        {
            barrel.draw();
        }
    }
}