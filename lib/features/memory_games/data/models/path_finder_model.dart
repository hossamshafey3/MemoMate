class PathNode {
  final int x;
  final int y;
  
  const PathNode(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathNode && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

enum NodeState {
  hidden,
  revealed,
  selectedCorrectly,
  selectedWrong,
}
