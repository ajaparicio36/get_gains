enum Muscles {
  bicep,
  tricep,
  forearm,
  rearDelt,
  sideDelt,
  frontDelt,
  lats,
  upperBack,
  upperChest,
  midLowerChest,
  abs,
  obliques,
  quads,
  hamstrings,
  calves,
  glutes;

  String get displayName {
    switch (this) {
      case Muscles.rearDelt:
        return 'Rear Delt';
      case Muscles.sideDelt:
        return 'Side Delt';
      case Muscles.frontDelt:
        return 'Front Delt';
      case Muscles.upperBack:
        return 'Upper Back';
      case Muscles.upperChest:
        return 'Upper Chest';
      case Muscles.midLowerChest:
        return 'Mid/Lower Chest';
      default:
        return name[0].toUpperCase() + name.substring(1);
    }
  }
}
