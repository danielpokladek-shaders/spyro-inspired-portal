using UnityEngine;

public class FirstPersonController : MonoBehaviour
{
    [Header("References")]
    [SerializeField]
    private Camera _camera;

    [Header("Movement")]
    [SerializeField]
    private float _walkSpeed = 3f;

    [SerializeField]
    private float _sprintMultiplier = 2f;

    [Header("Camera")]
    [SerializeField]
    private float _mouseSensitivity = 0.4f;

    [SerializeField]
    private float _verticalRange = 90f;

    private CharacterController _characterController;
    private InputSystem_Actions.PlayerActions _playerActions;
    private float _verticalRotation;
    private bool _isSprinting;

    private void Start()
    {
        _characterController = GetComponent<CharacterController>();

        _playerActions = InputController.PlayerActions;
        _playerActions.Sprint.performed += _ => _isSprinting = true;
        _playerActions.Sprint.canceled += _ => _isSprinting = false;
        _playerActions.Enable();

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    private void Update()
    {
        HandleMovement(_playerActions.Move.ReadValue<Vector2>());
        HandleRotation(_playerActions.Look.ReadValue<Vector2>());
    }

    private void HandleMovement(Vector2 moveVector)
    {
        float speedMultiplier = _walkSpeed * (_isSprinting ? _sprintMultiplier : 1f);

        float x = moveVector.x * speedMultiplier;
        float z = moveVector.y * speedMultiplier;

        Vector3 speed = new(x, 0, z);
        speed = transform.rotation * speed;

        _characterController.SimpleMove(speed);
    }

    private void HandleRotation(Vector2 rotationVector)
    {
        float horizontalInput = rotationVector.x * _mouseSensitivity;
        transform.Rotate(0, horizontalInput, 0);

        _verticalRotation -= rotationVector.y * _mouseSensitivity;
        _verticalRotation = Mathf.Clamp(_verticalRotation, -_verticalRange, _verticalRange);

        _camera.transform.localRotation = Quaternion.Euler(_verticalRotation, 0, 0);
    }
}
