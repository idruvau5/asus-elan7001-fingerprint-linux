# Verified hardware and Windows behavior

The ASUS Windows package binds `ACPI\ELAN7001` to `WbfSpiDriver.dll`, sets `WaitFingerPressType=2`, enables `SensorWaitFingerPress`, and sends one captured frame to the proprietary `EngineAdapter.dll` matcher.

The Linux patch preserves the sensor's press behavior, processes the complete native 96x96 frame, and uses SIGFM. The sensor is a narrow touch strip, so enrollment needs centered overlapping placements rather than arbitrary edges of the finger.
