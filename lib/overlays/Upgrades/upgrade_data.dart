import 'package:my_game/overlays/Upgrades/upgrade_tier.dart';
import 'package:my_game/player_stats.dart';

enum UpgradeType {
  fireRate,
  attackDamage,
  moveSpeed,
}

class UpgradeData {
  final String label;
  final String icon;
  final List<UpgradeTier> tiers;
  final void Function(PlayerStats stats, double value) effect;

  UpgradeData({
    required this.label,
    required this.icon,
    required this.tiers,
    required this.effect,
  });
}

final Map<UpgradeType, UpgradeData> upgradeRegistry = 
{
  UpgradeType.fireRate: UpgradeData(
    label: 'Attack Speed',
    icon: "icons/attack_speed.png",
    tiers: [
      UpgradeTier(value: 0.02, rarity: Rarity.common),
      UpgradeTier(value: 0.03, rarity: Rarity.rare),
      UpgradeTier(value: 0.05, rarity: Rarity.epic),
    ],
    effect: (stats, value) => stats.increaseFireRate(value),
  ),
  UpgradeType.attackDamage: UpgradeData(
    label: 'Attack Damage',
    icon: "icons/attack_damage.png",
    tiers: [
      UpgradeTier(value: 10, rarity: Rarity.common),
      UpgradeTier(value: 20, rarity: Rarity.rare),
      UpgradeTier(value: 35, rarity: Rarity.epic),
    ],
    effect: (stats, value) => stats.increaseDamage(value.toInt()),
  ),
  UpgradeType.moveSpeed: UpgradeData(
    label: 'Move Speed',
    icon: "icons/move_speed.png",
    tiers: [
      UpgradeTier(value: 5, rarity: Rarity.common),
      UpgradeTier(value: 8, rarity: Rarity.rare),
      UpgradeTier(value: 12, rarity: Rarity.epic),
    ],
    effect: (stats, value) => stats.increaseMoveSpeed (value),
  ),
};
