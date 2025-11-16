using UnityEngine;

public class SoundManager : MonoBehaviour
{
    public static SoundManager instance;

    public AudioClip ballRollSound;
    public AudioClip pinHitSound;
    public AudioClip strikeSound;
    public AudioClip spareSound;

    private AudioSource audioSource;

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
        audioSource = GetComponent<AudioSource>();
    }

    public void PlayBallRoll()
    {
        if (ballRollSound != null && !audioSource.isPlaying)
        {
            audioSource.clip = ballRollSound;
            audioSource.loop = true;
            audioSource.Play();
        }
    }

    public void StopBallRoll()
    {
        if (audioSource.isPlaying)
        {
            audioSource.Stop();
        }
    }

    public void PlayPinHit()
    {
        if (pinHitSound != null)
        {
            audioSource.PlayOneShot(pinHitSound, 0.7f);
        }
    }

    public void PlayStrike()
    {
        if (strikeSound != null)
        {
            audioSource.PlayOneShot(strikeSound);
        }
    }

    public void PlaySpare()
    {
        if (spareSound != null)
        {
            audioSource.PlayOneShot(spareSound);
        }
    }
}