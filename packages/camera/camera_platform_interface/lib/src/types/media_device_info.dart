class MediaDeviceInfo {
  const MediaDeviceInfo({
    this.deviceId,
    this.label,
    this.groupId,
    this.kind,
  });

  final String? deviceId;
  final String? label;
  final String? groupId;
  final String? kind;

  @override
  String toString() {
    return "MediaDeviceInfo($deviceId, $groupId, $kind, $label)";
  }
}
