import { useGame } from '../store/useGame.js';
import WelcomePanel from './panels/WelcomePanel.jsx';
import AllowancePanel from './panels/AllowancePanel.jsx';
import DistrictPanel from './panels/DistrictPanel.jsx';
import HelpPanel from './panels/HelpPanel.jsx';

// To add a new activity: create a panel and register it here, then point a
// location in data/locations.js at it.
const PANELS = {
  welcome: WelcomePanel,
  allowance: AllowancePanel,
  district: DistrictPanel,
  help: HelpPanel,
};

export default function Panels() {
  const active = useGame((s) => s.activePanel);
  const Panel = PANELS[active];
  return Panel ? <Panel /> : null;
}
