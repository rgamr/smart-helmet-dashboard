class Helmet {
  final String id;
  final String status;
  final int battery;
  final String? workerName;
  final String lastUpdate;

  const Helmet({
    required this.id,
    required this.status,
    required this.battery,
    this.workerName,
    required this.lastUpdate,
  });
}
