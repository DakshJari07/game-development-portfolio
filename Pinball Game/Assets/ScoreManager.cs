using UnityEngine;
using TMPro;

public class ScoreManager : MonoBehaviour
{
    public static ScoreManager instance;

    public TextMeshProUGUI scoreText;
    public TextMeshProUGUI highScoreText;
    public int currentScore = 0;
    private int highScore = 0;

    void Awake()
    {
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
        // Load saved high score from PlayerPrefs
        highScore = PlayerPrefs.GetInt("HighScore", 0);
        UpdateScoreUI();
        UpdateHighScoreUI();
    }

    public void AddScore(int points)
    {
        currentScore += points;

        // Check if new high score
        if (currentScore > highScore)
        {
            highScore = currentScore;
            PlayerPrefs.SetInt("HighScore", highScore);
            PlayerPrefs.Save();
            Debug.Log("NEW HIGH SCORE: " + highScore);
        }

        UpdateScoreUI();
        UpdateHighScoreUI();
    }

    void UpdateScoreUI()
    {
        if (scoreText != null)
        {
            scoreText.text = "Score: " + currentScore;
        }
    }

    void UpdateHighScoreUI()
    {
        if (highScoreText != null)
        {
            highScoreText.text = "High Score: " + highScore;
        }
    }

    public int GetHighScore()
    {
        return highScore;
    }

    public void ResetScore()
    {
        currentScore = 0;
        UpdateScoreUI();
    }
}