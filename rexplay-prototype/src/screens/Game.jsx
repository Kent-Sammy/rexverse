import { useEffect, useRef, useState } from 'react';
import { useCompact } from '../Phone.jsx';
import StatusBar from './StatusBar.jsx';
import { CloseButton, DARK_STATUS, DarkBackdrop, EndGameSheet } from './Crowdpurr.jsx';
import { PrimaryButton, Rays } from './GameResults.jsx';
import { Coin } from './Rewards.jsx';
import { Fill } from './parts.jsx';
import { HERO_ART, gameById, leaderboard, PLAYERS, pointsPerAnswer } from '../games.jsx';
import { FEATURES, REWARDS } from '../config.js';
import { bestRun, useStore } from '../store.jsx';

// The playable RexPlay game, styled like the dark Crowdpurr/results screens in Figma.
const LETTERS = ['A', 'B', 'C', 'D'];
const PTS = REWARDS.pointsName;

function Header({ title, onClose }) {
  return (
    <>
      <p className="absolute font-inter font-bold leading-[1.3] left-[22px] text-[#f1f5ff] text-[20px] top-[69px] whitespace-nowrap overflow-hidden text-ellipsis w-[300px]">
        {title}
      </p>
      <CloseButton onClick={onClose} />
    </>
  );
}

function Chip({ children }) {
  return (
    <div className="bg-[rgba(255,255,255,0.12)] rounded-[20px] px-[12px] py-[6px] font-inter font-semibold text-[12px] text-[#f1f5ff] whitespace-nowrap">
      {children}
    </div>
  );
}

function Intro({ game, perAnswer, playedToday, onStart, onLeave }) {
  const compact = useCompact();
  const poll = game.kind === 'poll';
  const n = game.questions.length;
  const steps = poll
    ? [`Answer ${n} quick questions`, `Earn ${perAnswer} ${PTS} for every answer`, 'See how other players answered']
    : [
        `Answer ${n} questions — ${game.seconds} seconds each`,
        `Earn ${perAnswer} ${PTS} for every correct answer`,
        'Climb the leaderboard: most correct answers wins, fastest breaks a tie',
      ];
  return (
    <>
      <Rays />
      <div className="absolute inset-x-0 top-[104px] bottom-0 flex flex-col">
        <div className={`flex-1 min-h-0 flex flex-col items-center ${compact ? 'gap-[6px] pb-[14px]' : 'gap-[8px] pb-[22px]'}`}>
          <div className="flex-1 min-h-[56px] max-h-[150px] w-[150px] relative animate-[pop-in_.5s_ease-out]">
            <Fill src={HERO_ART[game.art]} />
          </div>
          {FEATURES.liveGames && game.live && (
            <div className="flex items-center gap-[8px] shrink-0">
              <div className="bg-[#e44555] rounded-[12px] h-[20px] px-[9px] flex items-center gap-[4px]">
                <div className="size-[6px] rounded-full bg-white animate-pulse" />
                <p className="font-inter font-semibold text-[10px] text-white">Live Now</p>
              </div>
              <p className="font-inter font-semibold text-[12px] text-[#d7e4ff]">{PLAYERS} playing</p>
            </div>
          )}
          <div className="w-[340px] flex flex-col items-center gap-[6px] text-center shrink-0">
            <p className="font-inter font-bold text-[22px] leading-[1.2] tracking-[-0.44px] text-white">{game.title}</p>
            <p className="font-inter font-medium text-[14px] leading-[1.4] text-[#d7e4ff]">{game.body}</p>
          </div>
          <div className="flex gap-[8px] shrink-0 mt-[4px]">
            <Chip>{n} questions</Chip>
            <Chip>{game.seconds}s each</Chip>
            <Chip>
              Up to {n * perAnswer} {PTS}
            </Chip>
          </div>
        </div>

        <div
          className={`bg-white shrink-0 rounded-tl-[23px] rounded-tr-[23px] w-[402px] px-[24px] flex flex-col ${
            compact ? 'pt-[20px] pb-[18px] gap-[12px]' : 'pt-[24px] pb-[34px] gap-[14px]'
          }`}
        >
          {playedToday ? (
            <div className="flex-1 flex flex-col items-center justify-center text-center gap-[8px] py-[12px]">
              <p className="font-inter font-bold text-[14px] text-[#130f26]">You’ve played today’s challenge</p>
              <p className="font-inter font-medium text-[12px] leading-[1.45] text-[#6d7d9c] w-[300px]">
                A new Daily Challenge unlocks at midnight. Try a 10-question challenge in the meantime.
              </p>
            </div>
          ) : (
            <>
              <p className="font-inter font-bold text-[14px] text-[#130f26]">How to play</p>
              <div className="bg-[#f1f5ff] rounded-[11px] flex flex-col gap-[10px] p-[14px]">
                {steps.map((st, i) => (
                  <div key={st} className="flex items-center gap-[10px]">
                    <div className="size-[20px] shrink-0 rounded-full bg-[#002766] text-white font-inter font-semibold text-[10px] flex items-center justify-center">
                      {i + 1}
                    </div>
                    <p className="font-inter font-medium text-[12px] leading-[1.4] text-[#2e3d60]">{st}</p>
                  </div>
                ))}
              </div>
            </>
          )}
          <div className="mt-auto pt-[8px]">
            {playedToday ? (
              <PrimaryButton onClick={onLeave}>Back to RexPlay</PrimaryButton>
            ) : (
              <PrimaryButton onClick={onStart}>{poll ? 'Start Poll' : 'Start Game'}</PrimaryButton>
            )}
          </div>
        </div>
      </div>
    </>
  );
}

function Option({ letter, text, state, pct, onClick }) {
  // state: idle | correct | wrong | dim | chosen (poll) | poll
  const styles = {
    idle: 'bg-[#f1f5ff] border-transparent',
    correct: 'bg-[#e6f9e8] border-[#22a447]',
    wrong: 'bg-[#ffeef0] border-[#e44555]',
    dim: 'bg-[#f1f5ff] border-transparent opacity-55',
    chosen: 'bg-[#f1f5ff] border-[#5395ff]',
    poll: 'bg-[#f1f5ff] border-transparent',
  }[state];
  const circle = {
    correct: 'bg-[#22a447] text-white',
    wrong: 'bg-[#e44555] text-white',
    chosen: 'bg-[#2c6ef2] text-white',
  }[state] || 'bg-white text-[#002766]';
  const showPct = state === 'chosen' || state === 'poll';
  return (
    <button
      onClick={onClick}
      disabled={state !== 'idle'}
      className={`relative overflow-hidden w-full min-h-[50px] rounded-[11px] border-[1.5px] border-solid ${styles} flex items-center gap-[12px] px-[12px] py-[9px] text-left cursor-pointer disabled:cursor-default transition-all active:scale-[.98]`}
    >
      {showPct && (
        <div
          className={`absolute inset-y-0 left-0 ${state === 'chosen' ? 'bg-[#d6e4ff]' : 'bg-[#e3e9f7]'} transition-[width] duration-700 ease-out`}
          style={{ width: `${pct}%` }}
        />
      )}
      <div className={`relative size-[26px] shrink-0 rounded-full ${circle} font-inter font-bold text-[12px] flex items-center justify-center`}>
        {state === 'correct' ? '✓' : state === 'wrong' ? '✕' : letter}
      </div>
      <p className="relative flex-1 font-inter font-semibold text-[13px] leading-[1.3] text-[#130f26]">{text}</p>
      {showPct && <p className="relative font-inter font-bold text-[13px] text-[#002766]">{pct}%</p>}
    </button>
  );
}


function Question({ game, index, points, perAnswer, paused, onAnswer, onNext }) {
  const item = game.questions[index];
  const poll = game.kind === 'poll';
  const limit = game.seconds * 1000;
  const [choice, setChoice] = useState(null); // option index, or -1 when time ran out
  const [left, setLeft] = useState(limit);
  const [took, setTook] = useState(null); // seconds taken to answer
  const leftRef = useRef(limit);
  const compact = useCompact();
  const scroller = useRef(null);

  // Countdown that pauses while the "End game?" sheet is open.
  useEffect(() => {
    if (choice !== null || paused) return undefined;
    let last = performance.now();
    const t = setInterval(() => {
      const now = performance.now();
      leftRef.current = Math.max(0, leftRef.current - (now - last));
      last = now;
      setLeft(leftRef.current);
      if (leftRef.current <= 0) {
        clearInterval(t);
        setChoice(-1);
        setTook(game.seconds);
        onAnswer(false, game.seconds);
      }
    }, 100);
    return () => clearInterval(t);
  }, [choice, paused, game.seconds, onAnswer]);

  const pick = (i) => {
    if (choice !== null || paused) return;
    const seconds = Math.round((limit - leftRef.current) / 100) / 10;
    setChoice(i);
    setTook(seconds);
    onAnswer(poll ? true : i === item.answer, seconds);
  };

  const answered = choice !== null;
  const timedOut = choice === -1;
  const correct = !poll && choice === item.answer;

  useEffect(() => {
    if (answered && scroller.current) scroller.current.scrollTo({ top: scroller.current.scrollHeight, behavior: 'smooth' });
  }, [answered]);

  const seconds = Math.ceil(left / 1000);
  const last = index === game.questions.length - 1;
  const answerText = `${LETTERS[item.answer]}: ${item.options[item.answer]}`;

  const stateFor = (i) => {
    if (!answered) return 'idle';
    if (poll) return i === choice ? 'chosen' : 'poll';
    if (i === item.answer) return 'correct';
    if (i === choice) return 'wrong';
    return 'dim';
  };

  let headline;
  let detail;
  if (poll) {
    headline = `Thanks for sharing! +${perAnswer} ${PTS}`;
    detail = 'The bars show how other RexPlay players answered.';
  } else if (correct) {
    headline = `Correct! +${perAnswer} ${PTS}`;
    detail = item.explain;
  } else {
    headline = timedOut ? `Time’s up! The answer is ${answerText}` : `Not quite — the answer is ${answerText}`;
    detail = item.explain;
  }

  return (
    <>
      {/* Progress */}
      <div className="absolute left-[22px] right-[22px] top-[112px] flex items-center justify-between">
        <p className="font-inter font-semibold text-[14px] text-[#d7e4ff]">
          Question {index + 1} of {game.questions.length}
        </p>
        <div className="bg-white rounded-[40px] h-[31px] flex items-center gap-[6px] pl-[4px] pr-[12px]">
          <Coin size={24} />
          <p key={points} className="font-inter font-bold text-[13px] text-[#335285] animate-[pop-in_.35s_ease-out]">
            {points}
          </p>
        </div>
      </div>
      <div className="absolute left-[22px] right-[22px] top-[154px] flex gap-[4px]">
        {game.questions.map((_, i) => (
          <div
            key={i}
            className={`h-[4px] flex-1 rounded-full ${i < index || (i === index && answered) ? 'bg-white' : i === index ? 'bg-[#8fb6ff]' : 'bg-[rgba(255,255,255,0.2)]'}`}
          />
        ))}
      </div>

      {/* Timer: counts down while you think, then shows how long you took (or that time ran out) */}
      <div className="absolute left-[22px] right-[22px] top-[172px] flex items-center gap-[10px]">
        <div className="flex-1 h-[6px] rounded-full bg-[rgba(255,255,255,0.15)] overflow-hidden">
          <div
            className={`h-full rounded-full ${answered ? (timedOut ? 'bg-[#ff6b6b]' : 'bg-[rgba(255,255,255,0.45)]') : seconds <= 5 ? 'bg-[#ff6b6b]' : 'bg-[#7cf29c]'}`}
            style={{ width: `${(left / limit) * 100}%`, transition: 'width .1s linear' }}
          />
        </div>
        <p
          className={`font-inter font-bold text-[13px] text-right whitespace-nowrap ${
            answered ? (timedOut ? 'text-[#ff8f8f]' : 'text-[#d7e4ff]') : seconds <= 5 ? 'text-[#ff8f8f]' : 'text-white'
          }`}
        >
          {!answered ? `${seconds}s` : timedOut ? 'Time’s up' : `Answered in ${took}s`}
        </p>
      </div>

      {/* Question on top; answers panel below with the Next button pinned at its bottom. */}
      <div className="absolute inset-x-0 top-[196px] bottom-0 flex flex-col">
        <div className={`flex-[1_0_auto] px-[22px] pt-[8px] flex flex-col items-start gap-[10px] ${compact ? 'pb-[16px]' : 'pb-[22px]'}`}>
          <div className="bg-[rgba(255,255,255,0.12)] rounded-[20px] px-[10px] py-[4px] font-inter font-bold text-[10px] tracking-[0.4px] text-[#d7e4ff]">
            {item.topic || game.topic}
          </div>
          <p key={index} className={`font-inter font-bold leading-[1.28] tracking-[-0.3px] text-white animate-[slide-in_.25s_ease-out] ${compact ? 'text-[19px]' : 'text-[21px]'}`}>
            {item.question}
          </p>
        </div>

        <div className="flex-[0_1_494px] min-h-0 bg-white rounded-tl-[23px] rounded-tr-[23px] w-[402px] flex flex-col">
          <div ref={scroller} className="flex-1 min-h-0 overflow-y-auto overscroll-contain [scrollbar-width:none] px-[24px] pt-[20px] pb-[4px] flex flex-col gap-[10px]">
            {item.options.map((o, i) => (
              <Option key={`${index}-${i}`} letter={LETTERS[i]} text={o} state={stateFor(i)} pct={poll ? item.results[i] : 0} onClick={() => pick(i)} />
            ))}
            {answered && (
              <div className="mt-[4px] bg-[#eff2fe] rounded-[11px] p-[14px] flex flex-col gap-[4px] animate-[fade_.25s_ease-out] shrink-0">
                <p className={`font-inter font-bold text-[13px] leading-[1.35] ${poll || correct ? 'text-[#147f00]' : 'text-[#c62b3b]'}`}>{headline}</p>
                <p className="font-inter font-medium text-[12px] leading-[1.45] text-[#4f5a6e]">{detail}</p>
              </div>
            )}
          </div>
          <div className={`shrink-0 px-[25px] pt-[12px] ${compact ? 'pb-[18px]' : 'pb-[34px]'} ${answered ? 'animate-[fade_.25s_ease-out]' : 'invisible'}`}>
            <PrimaryButton onClick={onNext}>{last ? 'See Results' : 'Next Question'}</PrimaryButton>
          </div>
        </div>
      </div>
    </>
  );
}

export default function Game({ go, param }) {
  const game = gameById(param) || gameById('football-fever');
  const { addPlay, plays, multiplier } = useStore();
  const playedToday = !!game.daily && plays.some((p) => p.gameId === game.id);
  const [phase, setPhase] = useState('intro');
  const [index, setIndex] = useState(0);
  const [score, setScore] = useState(0);
  const [confirm, setConfirm] = useState(false);
  const run = useRef({ score: 0, time: 0 });
  const perAnswer = Math.round(pointsPerAnswer(game) * multiplier);

  const onAnswer = useRef((ok, seconds) => {
    run.current.time += seconds;
    if (ok) {
      run.current.score += 1;
      setScore(run.current.score);
    }
  }).current;

  const next = () => {
    if (index < game.questions.length - 1) {
      setIndex(index + 1);
      return;
    }
    const mine = { score: run.current.score, time: Math.round(run.current.time * 10) / 10 };
    const prev = bestRun(plays, game.id);
    const best = prev && (prev.score > mine.score || (prev.score === mine.score && prev.time <= mine.time)) ? prev : mine;
    const { rank } = leaderboard(game, { score: best.score, time: best.time });
    addPlay({ gameId: game.id, score: mine.score, total: game.questions.length, time: mine.time, rank, rawPoints: mine.score * pointsPerAnswer(game) });
    go('results', { replace: true });
  };

  return (
    <div className="bg-[#01296a] overflow-clip relative size-full">
      <DarkBackdrop />
      <StatusBar {...DARK_STATUS} />
      <Header title={game.title} onClose={() => (phase === 'intro' ? go('rexplay', { replace: true }) : setConfirm(true))} />
      {phase === 'intro' ? (
        <Intro game={game} perAnswer={perAnswer} playedToday={playedToday} onStart={() => setPhase('play')} onLeave={() => go('rexplay', { replace: true })} />
      ) : (
        <Question key={index} game={game} index={index} points={score * perAnswer} perAnswer={perAnswer} paused={confirm} onAnswer={onAnswer} onNext={next} />
      )}
      {confirm && <EndGameSheet onCancel={() => setConfirm(false)} onExit={() => go('rexplay', { replace: true })} />}
    </div>
  );
}
