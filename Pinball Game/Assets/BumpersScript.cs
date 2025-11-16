using UnityEngine;

public class Bumper : MonoBehaviour
{
    public int pointValue = 100;
    public float bounceForce = 10f;
    public Color hitColor = Color.white;
    private Color originalColor;
    private SpriteRenderer spriteRenderer;

    void Start()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        originalColor = spriteRenderer.color;
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        // Check if ball hit the bumper
        if (collision.gameObject.CompareTag("Ball"))
        {
            // Play bumper hit sound
            if (AudioManager.instance != null)
            {
                AudioManager.instance.PlayBumperHit();
            }

            // Add score
            if (ScoreManager.instance != null)
            {
                ScoreManager.instance.AddScore(pointValue);
            }

            // Push ball away with extra force
            Rigidbody2D ballRb = collision.gameObject.GetComponent<Rigidbody2D>();
            if (ballRb != null)
            {
                Vector2 pushDirection = (collision.transform.position - transform.position).normalized;
                ballRb.AddForce(pushDirection * bounceForce, ForceMode2D.Impulse);
            }

            // Flash color
            StartCoroutine(FlashColor());

            Debug.Log("Bumper hit! +" + pointValue + " points");
        }
    }

    System.Collections.IEnumerator FlashColor()
    {
        spriteRenderer.color = hitColor;
        yield return new WaitForSeconds(0.1f);
        spriteRenderer.color = originalColor;
    }
}