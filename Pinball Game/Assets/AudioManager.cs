using UnityEngine;

public class AudioManager : MonoBehaviour
{
    public static AudioManager instance;

    // Audio clips
    public AudioClip ballLaunchSound;
    public AudioClip flipperSound;
    public AudioClip bumperHitSound;
    public AudioClip targetLaneSound;
    public AudioClip gameOverSound;

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

    public void PlayBallLaunch()
    {
        PlaySound(ballLaunchSound);
    }

    public void PlayFlipper()
    {
        PlaySound(flipperSound, 0.5f);
    }

    public void PlayBumperHit()
    {
        PlaySound(bumperHitSound, 0.7f);
    }

    public void PlayTargetLane()
    {
        PlaySound(targetLaneSound, 0.6f);
    }

    public void PlayGameOver()
    {
        PlaySound(gameOverSound);
    }

    void PlaySound(AudioClip clip, float volume = 1f)
    {
        if (clip != null && audioSource != null)
        {
            audioSource.PlayOneShot(clip, volume);
        }
    }
}