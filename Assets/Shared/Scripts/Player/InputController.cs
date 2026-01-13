public static class InputController
{
    private static InputSystem_Actions _inputActions = new();

    public static InputSystem_Actions.PlayerActions PlayerActions => _inputActions.Player;
    public static InputSystem_Actions.UIActions UIActions => _inputActions.UI;

    public static void EnableControls() => _inputActions.Enable();

    public static void DisableControls() => _inputActions.Disable();
}
