class MediaDeviceInfo {
  const MediaDeviceInfo({
    this.deviceId,
    this.label,
  });

  final String? deviceId;
  final String? label;

  @override
  String toString() {
    return "MediaDeviceInfo( $deviceId, $label )";
  }
}
