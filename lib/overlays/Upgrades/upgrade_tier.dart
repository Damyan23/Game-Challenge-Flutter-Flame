enum Rarity { common, rare, epic }

class UpgradeTier {
  final double value;
  final Rarity rarity;

  UpgradeTier({ required this.value, required this.rarity });
}
