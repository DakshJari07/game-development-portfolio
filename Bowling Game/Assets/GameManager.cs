using UnityEngine;
using TMPro;

public class GameManager : MonoBehaviour
{
    public static GameManager instance;

    public TextMeshProUGUI scoreText;
    public StrikeSparePopup popupManager;
    public TextMeshProUGUI frameText;

    private int currentFrame = 1;
    private int currentRoll = 1;
    private int totalScore = 0;
    private int pinsKnockedThisRoll = 0;
    private int pinsKnockedFirstRoll = 0;

    void Awake()
    {
        instance = this;
    }

    void Start()
    {
        UpdateUI();
    }

    public void OnBallThrown()
    {
        // Count pins after a short delay
        Invoke("CountPins", 7f);
    }

    void CountPins()
    {
        GameObject[] pins = GameObject.FindGameObjectsWithTag("Pin");
        int pinsKnockedDown = 0;

        Debug.Log("=== Counting Pins ===");
        Debug.Log("Total pins found: " + pins.Length);

        foreach (GameObject pin in pins)
        {
            float pinY = pin.transform.position.y;
            float zRotation = pin.transform.eulerAngles.z;

            // Convert rotation to -180 to 180 range
            if (zRotation > 180f)
                zRotation = zRotation - 360f;

            Debug.Log(pin.name + " - Y: " + pinY.ToString("F2") + ", Z Rotation: " + zRotation.ToString("F2"));

            // A pin is knocked down if it's tilted more than 30 degrees
            // (Much more lenient than before)
            bool isTilted = Mathf.Abs(zRotation) > 30f && Mathf.Abs(zRotation) < 330f;

            if (isTilted)
            {
                pinsKnockedDown++;
                Debug.Log(pin.name + " is KNOCKED DOWN (Tilted: " + zRotation.ToString("F2") + " degrees)");
            }
            else
            {
                Debug.Log(pin.name + " is STANDING");
            }
        }

        pinsKnockedThisRoll = pinsKnockedDown;

        Debug.Log("*** Pins knocked down: " + pinsKnockedThisRoll + " ***");

        // Update score
        if (currentRoll == 1)
        {
            Debug.Log("Roll 1 - Pins knocked: " + pinsKnockedThisRoll);

            pinsKnockedFirstRoll = pinsKnockedThisRoll;
            totalScore += pinsKnockedThisRoll;

            Debug.Log("Total score after roll 1: " + totalScore);

            // Check for strike
            if (pinsKnockedThisRoll == 10)
            {
                Debug.Log("STRIKE!");
                if (pinsKnockedThisRoll == 10)
                {
                    Debug.Log("STRIKE!");
                    if (popupManager != null)
                        popupManager.ShowStrike();
                    if (SoundManager.instance != null)
                        SoundManager.instance.PlayStrike();
                    NextFrame();
                }
                NextFrame();
            }
            else
            {
                currentRoll = 2;
                Debug.Log("Moving to roll 2");

                // Hide knocked down pins before roll 2
                HideKnockedPins();
            }
        }
        else // Roll 2
        {
            Debug.Log("Roll 2 calculation:");
            Debug.Log("Pins knocked THIS roll: " + pinsKnockedThisRoll);
            Debug.Log("Pins knocked FIRST roll: " + pinsKnockedFirstRoll);

            int pinsThisRoll = pinsKnockedThisRoll - pinsKnockedFirstRoll;
            Debug.Log("Pins knocked in roll 2 only: " + pinsThisRoll);

            totalScore += pinsThisRoll;

            Debug.Log("New total score: " + totalScore);

            // Check for spare
            if (pinsKnockedThisRoll == 10)
            {
                Debug.Log("SPARE!");
                if (pinsKnockedThisRoll == 10)
                {
                    Debug.Log("SPARE!");
                    if (popupManager != null)
                        popupManager.ShowSpare();
                    if (SoundManager.instance != null)
                        SoundManager.instance.PlaySpare();  
                }
            }

            NextFrame();
        }

        UpdateUI();
    }

    void HideKnockedPins()
    {
        GameObject[] pins = GameObject.FindGameObjectsWithTag("Pin");

        foreach (GameObject pin in pins)
        {
            float zRotation = pin.transform.eulerAngles.z;

            // Convert rotation to -180 to 180 range
            if (zRotation > 180f)
                zRotation = zRotation - 360f;

            // If pin is knocked down (tilted more than 30 degrees)
            bool isTilted = Mathf.Abs(zRotation) > 30f && Mathf.Abs(zRotation) < 330f;

            if (isTilted)
            {
                // Hide the knocked down pin
                pin.SetActive(false);
            }
        }
    }

    void NextFrame()
    {
        Debug.Log("=== NEXT FRAME ===");
        Debug.Log("Score before next frame: " + totalScore);

        currentFrame++;
        currentRoll = 1;
        pinsKnockedFirstRoll = 0;

        Debug.Log("Moving to Frame: " + currentFrame);
        Debug.Log("Score after next frame: " + totalScore);

        if (currentFrame > 10)
        {
            Debug.Log("Game Over! Final Score: " + totalScore);
            currentFrame = 10; // Keep it at 10
        }
        else
        {
            // Reset pins
            Invoke("ResetPins", 2f);
        }
    }

    void ResetPins()
    {
        // Find ALL pins, even inactive ones
        GameObject[] allObjects = Resources.FindObjectsOfTypeAll<GameObject>();
        GameObject[] pins = System.Array.FindAll(allObjects, obj => obj.CompareTag("Pin") && obj.scene.IsValid());

        Debug.Log("Resetting " + pins.Length + " pins");

        // Pin positions
        Vector3[] pinPositions = new Vector3[]
        {
        new Vector3(0, 3, 0),
        new Vector3(-0.4f, 3.5f, 0),
        new Vector3(0.4f, 3.5f, 0),
        new Vector3(-0.8f, 4, 0),
        new Vector3(0, 4, 0),
        new Vector3(0.8f, 4, 0),
        new Vector3(-1.2f, 4.5f, 0),
        new Vector3(-0.4f, 4.5f, 0),
        new Vector3(0.4f, 4.5f, 0),
        new Vector3(1.2f, 4.5f, 0)
        };

        // Make sure all pins are visible again
        foreach (GameObject pin in pins)
        {
            pin.SetActive(true);
        }

        for (int i = 0; i < pins.Length && i < pinPositions.Length; i++)
        {
            pins[i].transform.position = pinPositions[i];
            pins[i].transform.rotation = Quaternion.identity;

            Rigidbody2D rb = pins[i].GetComponent<Rigidbody2D>();
            if (rb != null)
            {
                rb.linearVelocity = Vector2.zero;
                rb.angularVelocity = 0f;
            }
        }
    }

    void UpdateUI()
    {
        scoreText.text = "Score: " + totalScore;
        frameText.text = "Frame: " + currentFrame + "\nRoll: " + currentRoll;
    }
}