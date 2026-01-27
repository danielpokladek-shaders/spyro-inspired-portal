using UnityEngine;

public static class FrustumUtility
{
    public static bool IsVisibleFrom(Camera cam, Renderer renderer)
    {
        Plane[] planes = GeometryUtility.CalculateFrustumPlanes(cam);
        return GeometryUtility.TestPlanesAABB(planes, renderer.bounds);
    }
}

public class Portal : MonoBehaviour
{
    [SerializeField]
    private GameObject _portalFace;

    [SerializeField]
    private Renderer _portalFaceRenderer;

    private Camera _mainCamera;

    private float _faceInitialYRotation;

    private void Awake()
    {
        _mainCamera = Camera.main;

        _faceInitialYRotation = _portalFace.transform.localRotation.y;
    }

    private void Update()
    {
        if (!FrustumUtility.IsVisibleFrom(_mainCamera, _portalFaceRenderer))
        {
            _portalFace.SetActive(false);
        }
        else
        {
            _portalFace.SetActive(true);
            UpdateRotation();
        }
    }

    private void UpdateRotation()
    {
        Vector3 toCamera = (_mainCamera.transform.position - transform.position).normalized;
        float dot = Vector3.Dot(transform.forward, toCamera);

        bool isFlipped = dot > 0f;

        Vector3 newRotation = new(
            0,
            isFlipped ? _faceInitialYRotation : _faceInitialYRotation - 180,
            0
        );

        _portalFace.transform.localRotation = Quaternion.Euler(newRotation);
    }
}
