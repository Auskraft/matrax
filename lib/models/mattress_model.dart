enum MattressShape { square, rect }

enum Side { a, b }

enum Direction { north, east, south, west }

class MattressState {
  final MattressShape shape;
  final int step;
  final DateTime? lastChange;

  const MattressState({
    this.shape = MattressShape.square,
    this.step = 1,
    this.lastChange,
  });

  Side get side {
    if (shape == MattressShape.square) {
      return (step == 1 || step == 3) ? Side.a : Side.b;
    } else {
      return step == 1 ? Side.a : Side.b;
    }
  }

  Direction get direction {
    if (shape == MattressShape.square) {
      switch (step) {
        case 1: return Direction.north;
        case 2: return Direction.west;
        case 3: return Direction.south;
        case 4: return Direction.east;
        default: return Direction.north;
      }
    } else {
      return step == 1 ? Direction.north : Direction.south;
    }
  }

  int get maxSteps => shape == MattressShape.square ? 4 : 2;

  MattressState nextStep() {
    final nextStep = (step % maxSteps) + 1;
    return MattressState(
      shape: shape,
      step: nextStep,
      lastChange: DateTime.now(),
    );
  }

  MattressState withShape(MattressShape newShape) {
    return MattressState(shape: newShape, step: 1, lastChange: lastChange);
  }

  Map<String, dynamic> toJson() => {
    'shape': shape.name,
    'step': step,
    'lastChange': lastChange?.millisecondsSinceEpoch,
  };

  factory MattressState.fromJson(Map<String, dynamic> json) {
    return MattressState(
      shape: json['shape'] == 'rect' ? MattressShape.rect : MattressShape.square,
      step: json['step'] ?? 1,
      lastChange: json['lastChange'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastChange'])
          : null,
    );
  }
}

class LogEntry {
  final DateTime timestamp;
  final MattressShape shape;
  final Side fromSide;
  final Direction fromDir;
  final Side toSide;
  final Direction toDir;
  final bool flipped;
  final bool rotated;
  final bool turned;

  const LogEntry({
    required this.timestamp,
    required this.shape,
    required this.fromSide,
    required this.fromDir,
    required this.toSide,
    required this.toDir,
    required this.flipped,
    this.rotated = false,
    this.turned = false,
  });

  Map<String, dynamic> toJson() => {
    'ts': timestamp.millisecondsSinceEpoch,
    'shape': shape.name,
    'from': {'side': fromSide.name, 'dir': fromDir.name},
    'to': {'side': toSide.name, 'dir': toDir.name},
    'flipped': flipped,
    'rotated': rotated,
    'turned': turned,
  };

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['ts']),
      shape: json['shape'] == 'rect' ? MattressShape.rect : MattressShape.square,
      fromSide: json['from']['side'] == 'b' ? Side.b : Side.a,
      fromDir: _dirFromString(json['from']['dir']),
      toSide: json['to']['side'] == 'b' ? Side.b : Side.a,
      toDir: _dirFromString(json['to']['dir']),
      flipped: json['flipped'] ?? false,
      rotated: json['rotated'] ?? false,
      turned: json['turned'] ?? false,
    );
  }

  static Direction _dirFromString(String s) {
    switch (s) {
      case 'east': return Direction.east;
      case 'south': return Direction.south;
      case 'west': return Direction.west;
      default: return Direction.north;
    }
  }
}