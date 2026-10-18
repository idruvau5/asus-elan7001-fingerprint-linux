# Verified hardware and Windows behavior

The ASUS Windows package binds `ACPI\ELAN7001` to `WbfSpiDriver.dll`, sets `WaitFingerPressType=2`, enables `SensorWaitFingerPress`, and sends one captured frame to the proprietary `EngineAdapter.dll` matcher.

The Linux patch preserves the sensor's press behavior, processes the complete native 96x96 frame, and uses SIGFM. It inserts a 100 ms poll interval while waiting for a touch, a short settle delay before the press frame, and an HID reset when capture is released. These match the Windows driver's bounded press cycle and avoid leaving the sensor array powered continuously. The sensor is a narrow touch strip, so enrollment needs centered overlapping placements rather than arbitrary edges of the finger.
