(DateTime, DateTime)? dateRangeFromKey(String key) {
  final parts = key.split(',');
  if (parts.length != 2) return null;
  final start = DateTime.tryParse(parts[0]);
  final end = DateTime.tryParse(parts[1]);
  if (start == null || end == null) return null;
  return (start, end);
}
