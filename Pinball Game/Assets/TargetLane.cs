using UnityEngine;

public class TargetLane : MonoBehaviour
{
    public int pointValue = 50;
    public Color hitColor = Color.white;
    public Color originalColor = Color.yellow;
    private SpriteRenderer spriteRenderer;

    void Start()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        if (spriteRenderer != null)
        {
            originalColor = spriteRenderer.color;
        }
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        // Check if ball entered the lane
        if (other.CompareTag("Ball"))
        {
            // Play target lane sound
            if (AudioManager.instance != null)
            {
                AudioManager.instance.PlayTargetLane();
            }

            // Add score
            if (ScoreManager.instance != null)
            {
                ScoreManager.instance.AddScore(pointValue);
                Debug.Log("Target lane hit! +" + pointValue + " points");
            }

            // Flash color
            if (spriteRenderer != null)
            {
                StartCoroutine(FlashColor());
            }
        }
    }

    System.Collections.IEnumerator FlashColor()
    {
        // Flash to hit color
        spriteRenderer.color = hitColor;
        yield return new WaitForSeconds(0.2f);

        // Return to original color
        spriteRenderer.color = originalColor;
    }
}