using UnityEngine;

public class BallController : MonoBehaviour
{
    private Vector3 startPosition;
    private Rigidbody2D rb;

    public float respawnY = -6f;
    public float respawnDelay = 1f;
    public float launchForce = 20f;

    private bool isLaunched = false;
    private float launchTime = 0f;
    private bool isRespawning = false;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        startPosition = transform.position;

        // Disable gravity at start so ball doesn't fall
        rb.gravityScale = 0f;
    }

    void Update()
    {
        // Only limit speed after ball has been launched for a bit
        if (isLaunched && Time.time - launchTime > 0.5f)
        {
            // Limit ball speed to prevent it flying off screen
            if (rb.linearVelocity.magnitude > 15f)
            {
                rb.linearVelocity = rb.linearVelocity.normalized * 15f;
            }
        }

        // Launch ball with spacebar (only if not already launched)
        if (Input.GetKeyDown(KeyCode.Space) && !isLaunched && !isRespawning)
        {
            LaunchBall();
        }

        // Check if ball fell below the table (only after launch and not already respawning)
        if (isLaunched && !isRespawning && transform.position.y < respawnY)
        {
            isRespawning = true;
            Invoke("RespawnBall", respawnDelay);
        }
    }

    /// <summary>
    /// Launch the ball up the launch lane
    /// </summary>
    void LaunchBall()
    {
        // Enable gravity
        rb.gravityScale = 1f;

        // Launch straight up
        Vector2 launchDirection = Vector2.up;
        rb.AddForce(launchDirection * launchForce, ForceMode2D.Impulse);

        isLaunched = true;
        launchTime = Time.time;

        // Play launch sound
        if (AudioManager.instance != null)
        {
            AudioManager.instance.PlayBallLaunch();
        }

        Debug.Log("Ball launched!");
    }

    /// <summary>
    /// Reset ball to starting position when it falls off
    /// </summary>
    void RespawnBall()
    {
        // Tell GameManager we lost a ball
        if (GameManager.instance != null)
        {
            GameManager.instance.LoseBall();
        }

        // Only respawn if we have balls left
        if (GameManager.instance != null && GameManager.instance.ballsRemaining > 0)
        {
            // Reset ball to starting position
            transform.position = startPosition;

            // Stop all movement
            rb.linearVelocity = Vector2.zero;
            rb.angularVelocity = 0f;

            // Disable gravity again
            rb.gravityScale = 0f;

            isLaunched = false;
            isRespawning = false;

            Debug.Log("Ball respawned! Balls remaining: " + GameManager.instance.ballsRemaining + ". Press SPACE to launch.");
        }
        else
        {
            // Game is over - hide the ball
            gameObject.SetActive(false);
            Debug.Log("No balls remaining - Game Over!");
        }
    }

    /// <summary>
    /// Reset ball without losing a life (for testing or special events)
    /// </summary>
    public void ResetBallPosition()
    {
        transform.position = startPosition;
        rb.linearVelocity = Vector2.zero;
        rb.angularVelocity = 0f;
        rb.gravityScale = 0f;
        isLaunched = false;
        isRespawning = false;
    }
}