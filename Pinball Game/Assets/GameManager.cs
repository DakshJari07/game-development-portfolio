using UnityEngine;
using TMPro;

public class GameManager : MonoBehaviour
{
    public static GameManager instance;

    // Ball tracking
    public int ballsRemaining = 3;
    public int maxBalls = 3;

    // UI references
    public TextMeshProUGUI ballsText;
    public GameObject gameOverPanel;

    void Awake()
    {
        // Singleton pattern - only one GameManager exists
        if (instance == null)
        {
            instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    void Start()
    {
        UpdateBallsUI();

        // Hide game over panel at start
        if (gameOverPanel != null)
        {
            gameOverPanel.SetActive(false);
        }
    }

    void Update()
    {
        // Press R to restart after game over
        if (ballsRemaining <= 0 && Input.GetKeyDown(KeyCode.R))
        {
            RestartGame();
        }
    }

    /// <summary>
    /// Called when player loses a ball
    /// </summary>
    public void LoseBall()
    {
        ballsRemaining--;
        UpdateBallsUI();

        if (ballsRemaining <= 0)
        {
            GameOver();
        }
        else
        {
            Debug.Log("Balls remaining: " + ballsRemaining);
        }
    }

    /// <summary>
    /// Update the balls remaining UI display
    /// </summary>
    void UpdateBallsUI()
    {
        if (ballsText != null)
        {
            ballsText.text = "Balls: " + ballsRemaining;
        }
    }

    /// <summary>
    /// Called when game is over (no balls left)
    /// </summary>
    void GameOver()
    {
        int finalScore = 0;
        if (ScoreManager.instance != null)
        {
            finalScore = ScoreManager.instance.currentScore;
        }

        Debug.Log("=== GAME OVER CALLED ===");
        Debug.Log("Final Score: " + finalScore);

        // Play game over sound
        if (AudioManager.instance != null)
        {
            AudioManager.instance.PlayGameOver();
        }

        // Show the entire game over panel
        if (gameOverPanel != null)
        {
            // First, activate the panel
            gameOverPanel.SetActive(true);

            // Find and update the text component
            TextMeshProUGUI textComponent = gameOverPanel.GetComponentInChildren<TextMeshProUGUI>(true);
            if (textComponent != null)
            {
                // Make sure text GameObject is active
                textComponent.gameObject.SetActive(true);

                // Set the text
                textComponent.text = "GAME OVER\nFinal Score: " + finalScore + "\n\nPress R to Restart";

                // Force enable the text component
                textComponent.enabled = true;

                // Make sure alpha is 255 (fully visible)
                Color color = textComponent.color;
                color.a = 1f;
                textComponent.color = color;
            }
        }

        // Pause the game
        Time.timeScale = 0f;
    }

    /// <summary>
    /// Restart the game scene
    /// </summary>
    public void RestartGame()
    {
        // Unpause time
        Time.timeScale = 1f;

        // Reload current scene
        UnityEngine.SceneManagement.SceneManager.LoadScene(
            UnityEngine.SceneManagement.SceneManager.GetActiveScene().name
        );
    }

    /// <summary>
    /// Reset game state without reloading scene
    /// </summary>
    public void ResetGame()
    {
        ballsRemaining = maxBalls;
        UpdateBallsUI();

        if (gameOverPanel != null)
        {
            gameOverPanel.SetActive(false);
        }

        Time.timeScale = 1f;

        Debug.Log("Game reset!");
    }
}