using UnityEngine;
using UnityEngine.UI;

public class BallController : MonoBehaviour
{
    private Rigidbody2D rb;
    private Vector2 startMousePos;
    private Vector2 startBallPos;
    private bool isDragging = false;
    private bool hasThrown = false;

    public float powerMultiplier = 3f;
    public float maxPower = 15f;

    // Aim and power display
    public LineRenderer aimLine;
    public GameObject aimLineObject;
    public Slider powerMeter;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        startBallPos = transform.position;

        // Set up LineRenderer if we're using it
        if (aimLine != null)
        {
            aimLine.positionCount = 2;
            aimLine.startWidth = 0.1f;
            aimLine.endWidth = 0.05f;
            aimLine.material = new Material(Shader.Find("Sprites/Default"));
            aimLine.startColor = Color.yellow;
            aimLine.endColor = Color.red;
        }
    }

    void Update()
    {
        if (!hasThrown)
        {
            if (Input.GetMouseButtonDown(0))
            {
                startMousePos = Camera.main.ScreenToWorldPoint(Input.mousePosition);
                isDragging = true;
                // Show aim line and power meter
                if (aimLineObject != null)
                    aimLineObject.SetActive(true);
                if (powerMeter != null)
                    powerMeter.gameObject.SetActive(true);
            }
            if (isDragging && Input.GetMouseButton(0))
            {
                // Update aim line
                Vector2 currentMousePos = Camera.main.ScreenToWorldPoint(Input.mousePosition);
                Vector2 direction = currentMousePos - startMousePos;
                UpdateAimLine(direction);
                UpdatePowerMeter(direction.magnitude);
            }
            if (Input.GetMouseButtonUp(0) && isDragging)
            {
                Vector2 endMousePos = Camera.main.ScreenToWorldPoint(Input.mousePosition);
                Vector2 direction = endMousePos - startMousePos;
                // Hide indicators
                if (aimLineObject != null)
                    aimLineObject.SetActive(false);
                if (powerMeter != null)
                    powerMeter.gameObject.SetActive(false);
                // Limit the power
                float power = Mathf.Min(direction.magnitude * powerMultiplier, maxPower);
                // Apply force
                rb.AddForce(direction.normalized * power, ForceMode2D.Impulse);
                isDragging = false;
                hasThrown = true;
                GameManager.instance.OnBallThrown();
            }
        }
        // Reset if ball goes too far or stops
        if (hasThrown && (transform.position.y > 10 || rb.linearVelocity.magnitude < 0.1f))
        {
            Invoke("ResetBall", 2f);
        }

        // Play rolling sound when ball is moving
        if (hasThrown && rb.linearVelocity.magnitude > 0.5f)
        {
            if (SoundManager.instance != null)
                SoundManager.instance.PlayBallRoll();
        }
        else
        {
            if (SoundManager.instance != null)
                SoundManager.instance.StopBallRoll();
        }
    }

    void UpdateAimLine(Vector2 direction)
    {
        if (aimLine != null)
        {
            aimLine.SetPosition(0, transform.position);
            Vector2 endPos = (Vector2)transform.position + direction.normalized * Mathf.Min(direction.magnitude * 2, 5f);
            aimLine.SetPosition(1, endPos);
        }

        // Alternative: Use the sprite line
        if (aimLineObject != null && aimLine == null)
        {
            Vector2 ballPos = transform.position;
            aimLineObject.transform.position = ballPos;

            // Point towards drag direction
            float angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg;
            aimLineObject.transform.rotation = Quaternion.Euler(0, 0, angle - 90);

            // Scale based on power
            float length = Mathf.Min(direction.magnitude * 2, 5f);
            aimLineObject.transform.localScale = new Vector3(0.1f, length, 1);
        }
    }

    void UpdatePowerMeter(float dragDistance)
    {
        if (powerMeter != null)
        {
            float normalizedPower = Mathf.Clamp01(dragDistance / (maxPower / powerMultiplier));
            powerMeter.value = normalizedPower;

            // Change color based on power (green -> yellow -> red)
            Image fillImage = powerMeter.fillRect.GetComponent<Image>();
            if (fillImage != null)
            {
                fillImage.color = Color.Lerp(Color.green, Color.red, normalizedPower);
            }
        }
    }

    void ResetBall()
    {
        transform.position = startBallPos;
        rb.linearVelocity = Vector2.zero;
        rb.angularVelocity = 0f;
        hasThrown = false;
    }
}