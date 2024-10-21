enum BikeState {
  available,
  inUse,
  maintenance,
  lost,
}

String getBikeStateDisplayName(BikeState state) {
  switch (state) {
    case BikeState.available:
      return 'available';
    case BikeState.inUse:
      return 'in use';
    case BikeState.maintenance:
      return 'maintenance';
    case BikeState.lost:
      return 'lost';
    default:
      return 'unknown';
  }
}