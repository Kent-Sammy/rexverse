// Missions run in order; the first incomplete one is shown as the daily mission.
// To add a mission: add an entry here and call `completeMission(id)` (or a
// dedicated store action) when the player achieves it.
export const MISSIONS = [
  {
    id: 'first-allowance',
    title: 'Your First Allowance',
    objective: 'Collect ₦10,000 from home and decide how to spend, save and invest it.',
    where: 'Home — porch table',
    target: 'allowance',
    xp: 'Up to 150 XP',
  },
  {
    id: 'visit-district',
    title: 'Find the Financial District',
    objective: 'Walk north up the street and enter the Financial District gateway.',
    where: 'North end of the street',
    target: 'gateway',
    xp: '50 XP',
    reward: 50,
  },
];
