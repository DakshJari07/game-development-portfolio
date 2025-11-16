using UnityEngine;

public class FlipperController : MonoBehaviour
{
    public bool isLeftFlipper = true;
    public KeyCode flipKey;

    private float restRotation = 0f;
    private float pressedRotation = 45f;
    private Rigidbody2D rb;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();

        if (isLeftFlipper)
        {
            restRotation = 30f;
            pressedRotation = 75f;
            flipKey = KeyCode.A;
        }
        else
        {
            restRotation = -30f;
            pressedRotation = -75f;
            flipKey = KeyCode.D;
        }
    }

    void Update()
    {
        // Play sound when flipper is pressed
        if (Input.GetKeyDown(flipKey))
        {
            if (AudioManager.instance != null)
            {
                AudioManager.instance.PlayFlipper();
            }
        }

        // Rotate flipper based on key press
        if (Input.GetKey(flipKey))
        {
            transform.rotation = Quaternion.Euler(0, 0, pressedRotation);
        }
        else
        {
            transform.rotation = Quaternion.Euler(0, 0, restRotation);
        }
    }

    // Add extra bounce when flipper hits ball
    void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.CompareTag("Ball"))
        {
            Rigidbody2D ballRb = collision.gameObject.GetComponent<Rigidbody2D>();
            if (ballRb != null && Input.GetKey(flipKey))
            {
                // Add upward force when flipper hits ball
                Vector2 pushDirection = (collision.transform.position - transform.position).normalized;
                ballRb.AddForce(pushDirection * 5f, ForceMode2D.Impulse);
            }
        }
    }
}