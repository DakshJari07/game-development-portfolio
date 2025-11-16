using UnityEngine;
using UnityEngine.SceneManagement;

public class RestartGame : MonoBehaviour
{
    public void Restart()
    {
        // Reload the current scene
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    // Optional: Can also add a quit button
    public void QuitGame()
    {
        Application.Quit();
        Debug.Log("Game Quit"); // This will show in editor since Quit doesn't work in editor
    }
}