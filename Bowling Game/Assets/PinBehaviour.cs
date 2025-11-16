using UnityEngine;

public class PinBehavior : MonoBehaviour
{
    private Rigidbody2D rb;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        rb.centerOfMass = new Vector2(0, 0.2f);
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        // When ball or another pin hits this pin
        if (collision.gameObject.CompareTag("Ball") || collision.gameObject.CompareTag("Pin"))
        {
            // Play sound
            if (SoundManager.instance != null)
                SoundManager.instance.PlayPinHit();

            // Get the collision point
            Vector2 hitPoint = collision.contacts[0].point;
            Vector2 pinCenter = transform.position;

            // Calculate which side was hit
            float hitSide = hitPoint.x - pinCenter.x;

            // Apply torque to make it tip over
            float torque = hitSide * 300f;
            rb.AddTorque(-torque);

            // Also push it in the direction of impact
            Vector2 pushDirection = (pinCenter - hitPoint).normalized;
            rb.AddForce(pushDirection * 2f, ForceMode2D.Impulse);
        }
    }
}