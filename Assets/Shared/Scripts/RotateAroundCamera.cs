using UnityEngine;

public class RotateAroundCamera : MonoBehaviour
{
    [SerializeField]
    private Transform _target;

    [SerializeField]
    private Vector3 _cameraOffset;

    private void Start()
    {
        transform.position = _cameraOffset;
    }

    private void Update()
    {
        transform.LookAt(_target);
        transform.RotateAround(_target.position, Vector3.up, 90f * Time.deltaTime);
    }
}
