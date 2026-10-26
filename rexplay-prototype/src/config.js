// RexPlay settings in one place.
//
// ⚠️  The rewards numbers below are PLACEHOLDERS for the prototype. Points issuance limits,
// redemption values, eligibility and the RexVault benefits still need to be agreed (and the
// RexVault benefits approved by Compliance) before launch.

export const REWARDS = {
  pointsName: 'RexPoints',

  // Earning
  pointsPerCorrect: 10, // 10-question challenge → up to 100 RexPoints
  dailyChallengePointsPerCorrect: 20, // 5-question Daily Challenge → up to 100 RexPoints
  dailyEarnCap: 300, // most RexPoints one customer can earn per day (all games combined)

  // Redemption
  pointsPerNaira: 10, // 10 RexPoints = ₦1
  dailyBudgetNaira: 25000, // total rewards paid out across all customers per day
  // Value of each redemption option, in naira (RexPoints needed = naira × pointsPerNaira)
  airtimeNaira: [50, 100, 200, 500, 1000, 2000],
  dataNaira: [100, 200, 500, 1000, 1500, 2000],
  cashNaira: [100, 200, 500, 1000, 2000, 5000],
};

// Extra benefits for qualifying RexVault customers (pending Compliance approval).
// Everyone can play; RexVault customers earn more and can redeem for cash.
export const REXVAULT = {
  enabled: true,
  pointsMultiplier: 1.5, // RexVault customers earn 1.5× RexPoints per correct answer
  dailyEarnCap: 450, // and have a higher daily cap
  cashRedemptionVaultOnly: true, // cash rewards only for RexVault customers
};

// Launch scope: trivia across four categories, a simple leaderboard and RexPoints.
// The other prototype features are kept but switched off.
export const FEATURES = {
  dailyChallenge: true,
  polls: false,
  liveGames: false,
  redeemAirtime: true,
  redeemData: true,
  redeemCash: true,
};

// Prototype-only helpers for demos (turn off for real customers).
export const DEMO = {
  tools: true, // shows "Demo: add 1,000 RexPoints" and the RexVault on/off switch
  bonusPoints: 1000,
};

export const toNaira = (points) => Math.floor(points / REWARDS.pointsPerNaira);
export const toPoints = (naira) => naira * REWARDS.pointsPerNaira;
