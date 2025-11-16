using UnityEngine;
using TMPro;
using System.Collections;

public class StrikeSparePopup : MonoBehaviour
{
    public TextMeshProUGUI popupText;

    public void ShowStrike()
    {
        ShowPopup("STRIKE!", Color.yellow);
    }

    public void ShowSpare()
    {
        ShowPopup("SPARE!", Color.green);
    }

    void ShowPopup(string message, Color color)
    {
        popupText.text = message;
        popupText.color = color;
        popupText.gameObject.SetActive(true);

        // Start animation
        StartCoroutine(AnimatePopup());
    }

    IEnumerator AnimatePopup()
    {
        // Start small
        popupText.transform.localScale = Vector3.zero;

        // Grow to full size
        float timer = 0;
        while (timer < 0.3f)
        {
            timer += Time.deltaTime;
            float scale = Mathf.Lerp(0, 1.2f, timer / 0.3f);
            popupText.transform.localScale = Vector3.one * scale;
            yield return null;
        }

        // Settle to normal size
        timer = 0;
        while (timer < 0.2f)
        {
            timer += Time.deltaTime;
            float scale = Mathf.Lerp(1.2f, 1f, timer / 0.2f);
            popupText.transform.localScale = Vector3.one * scale;
            yield return null;
        }

        // Wait
        yield return new WaitForSeconds(1.5f);

        // Fade out
        Color originalColor = popupText.color;
        timer = 0;
        while (timer < 0.5f)
        {
            timer += Time.deltaTime;
            float alpha = Mathf.Lerp(1, 0, timer / 0.5f);
            popupText.color = new Color(originalColor.r, originalColor.g, originalColor.b, alpha);
            yield return null;
        }

        // Hide
        popupText.gameObject.SetActive(false);
        popupText.color = originalColor; // Reset alpha
    }
}