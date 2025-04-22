class PlayerStats 
{
    int health = 3;
    double moveSpeed = 120;
    double attackSpeed = 1.0;
    int damage = 10;
    double fireRate = 0.2;
    double reloadSpeed = 1.5;
    double currentReloadTime = 0.0;
    double fireTimer = 0;
    double currentBullets = 0;
    double maxBullets = 10.0;

    double xpNeededForLevelUp = 15;
    double currentXP = 0;
    double xpIncreaseFraction = 10;
    int level = 1;

    void increaseHealth(int amount) {
        health += amount;
    }

    void increaseMoveSpeed(double amount) {
        moveSpeed += amount;
    }

    void increaseDamage(int amount) {
        damage += amount;
    }

    void increaseFireRate(double amount) {
        fireRate -= amount;
    }

    void increaseReloadSpeed(double amount) {
        reloadSpeed -= amount;
    }

    void addXp (double amout)
    {
      currentXP = amout;
    }
}
