
class AggregationSetup {
  final List<int> maxAggregationItems;

  final List<double> maxZoomLimits;

  final int markerSize;

  AggregationSetup({
    this.maxAggregationItems = const [10, 25, 50, 100, 500, 1000],
    this.maxZoomLimits = const [
      12,
      10
    ],
    this.markerSize = 150,
  })  : assert(maxAggregationItems.length == 6),
        assert(maxZoomLimits.length == 2),
        assert(markerSize > 0);
}
