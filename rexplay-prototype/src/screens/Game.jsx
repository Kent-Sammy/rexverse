import { useEffect, useRef, useState } from 'react';
import StatusBar from './StatusBar.jsx';
import { CloseButton, DARK_STATUS, DarkBackdrop, EndGameSheet } from './Crowdpurr.jsx';
import { PrimaryButton, Rays } from './GameResults.jsx';
import { Coin } from './Rewards.jsx';
import { Fill } from './parts.jsx';
import { HERO_ART, gameById, leaderboard, maxPoints, PLAYERS } from '../games.jsx';
import { useStore } from '../store.jsx';

// The playable RexPlay game, styled like the dark Crowdpurr/results screens in Figma.
const LETTERS = ['A', 'B', 'C', 'D'];

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

function Intro({ game, onStart }) {
  const poll = game.kind === 'poll';
  const steps = poll
    ? [`Answer ${game.questions.length} quick questions`, 'Earn 20 points for every answer', 'See how other players answered']
    : [
        `Answer ${game.questions.length} questions — ${game.seconds} seconds each`,
        'Earn 50 points for every correct answer',
        'Learn a money tip after every question',
      ];
  return (
    <>
      <Rays />
      <div className="-translate-x-1/2 absolute left-1/2 top-[112px] size-[150px] animate-[pop-in_.5s_ease-out]">
        <Fill src={HERO_ART[game.art]} />
      </div>
      {game.live && (
        <div className="-translate-x-1/2 absolute left-1/2 top-[268px] flex items-center gap-[8px]">
          <div className="bg-[#e44555] rounded-[12px] h-[20px] px-[9px] flex items-center gap-[4px]">
            <div className="size-[6px] rounded-full bg-white animate-pulse" />
            <p className="font-inter font-semibold text-[10px] text-white">Live Now</p>
          </div>
          <p className="font-inter font-semibold text-[12px] text-[#d7e4ff]">{PLAYERS} playing</p>
        </div>
      )}
      <div className="-translate-x-1/2 absolute left-1/2 top-[296px] w-[340px] flex flex-col items-center gap-[8px] text-center">
        <p className="font-inter font-bold text-[22px] leading-[1.2] tracking-[-0.44px] text-white">{game.title}</p>
        <p className="font-inter font-medium text-[14px] leading-[1.4] text-[#d7e4ff]">{game.body}</p>
      </div>
      <div className="-translate-x-1/2 absolute left-1/2 top-[384px] flex gap-[8px]">
        <Chip>{game.questions.length} questions</Chip>
        <Chip>{game.seconds}s each</Chip>
        <Chip>Up to {maxPoints(game)} pts</Chip>
      </div>

      <div className="absolute bg-white bottom-0 h-[436px] left-0 rounded-tl-[23px] rounded-tr-[23px] w-[402px]">
        <p className="absolute left-[24px] top-[28px] font-inter font-bold text-[16px] text-[#130f26]">How to play</p>
        <div className="absolute left-[24px] top-[64px] w-[354px] flex flex-col gap-[12px]">
          {steps.map((s, i) => (
            <div key={s} className="bg-[#f1f5ff] rounded-[11px] flex items-center gap-[12px] p-[14px]">
              <div className="size-[28px] shrink-0 rounded-full bg-[#002766] text-white font-inter font-bold text-[13px] flex items-center justify-center">
                {i + 1}
              </div>
              <p className="font-inter font-medium text-[13px] leading-[1.4] text-[#2e3d60]">{s}</p>
            </div>
          ))}
        </div>
        <div className="absolute left-[25px] bottom-[50px] w-[351px]">
          <PrimaryButton onClick={onStart}>{poll ? 'Start Poll' : 'Start Game'}</PrimaryButton>
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
      className={`relative overflow-hidden w-full min-h-[54px] rounded-[12px] border-[1.5px] border-solid ${styles} flex items-center gap-[12px] px-[12px] py-[10px] text-left cursor-pointer disabled:cursor-default transition-all active:scale-[.98]`}
    >
      {showPct && (
        <div
          className={`absolute inset-y-0 left-0 ${state === 'chosen' ? 'bg-[#d6e4ff]' : 'bg-[#e3e9f7]'} transition-[width] duration-700 ease-out`}
          style={{ width: `${pct}%` }}
        />
      )}
      <div className={`relative size-[28px] shrink-0 rounded-full ${circle} font-inter font-bold text-[13px] flex items-center justify-center`}>
        {state === 'correct' ? '✓' : state === 'wrong' ? '✕' : letter}
      </div>
      <p className="relative flex-1 font-inter font-semibold text-[14px] leading-[1.3] text-[#130f26]">{text}</p>
      {showPct && <p className="relative font-inter font-bold text-[13px] text-[#002766]">{pct}%</p>}
    </button>
  );
}

function Question({ game, index, points, onAnswer, onNext }) {
  const item = game.questions[index];
  const poll = game.kind === 'poll';
  const [choice, setChoice] = useState(null); // option index, or -1 when time ran out
  const [left, setLeft] = useState(game.seconds * 1000);
  const started = useRef(Date.now());

  useEffect(() => {
    if (choice !== null) return undefined;
    const t = setInterval(() => {
      const remaining = game.seconds * 1000 - (Date.now() - started.current);
      if (remaining <= 0) {
        clearInterval(t);
        setLeft(0);
        setChoice(-1);
        onAnswer(false);
      } else setLeft(remaining);
    }, 100);
    return () => clearInterval(t);
  }, [choice, game.seconds, onAnswer]);

  const pick = (i) => {
    if (choice !== null) return;
    setChoice(i);
    onAnswer(poll ? true : i === item.answer);
  };

  const answered = choice !== null;
  const correct = !poll && choice === item.answer;
  const seconds = Math.ceil(left / 1000);
  const last = index === game.questions.length - 1;

  const stateFor = (i) => {
    if (!answered) return 'idle';
    if (poll) return i === choice ? 'chosen' : 'poll';
    if (i === item.answer) return 'correct';
    if (i === choice) return 'wrong';
    return 'dim';
  };

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

      {/* Timer */}
      <div className="absolute left-[22px] right-[22px] top-[172px] flex items-center gap-[10px]">
        <div className="flex-1 h-[6px] rounded-full bg-[rgba(255,255,255,0.15)] overflow-hidden">
          <div
            className={`h-full rounded-full ${seconds <= 5 ? 'bg-[#ff6b6b]' : 'bg-[#7cf29c]'}`}
            style={{ width: `${(left / (game.seconds * 1000)) * 100}%`, transition: 'width .1s linear' }}
          />
        </div>
        <p className={`font-inter font-bold text-[13px] w-[30px] text-right ${seconds <= 5 && !answered ? 'text-[#ff8f8f]' : 'text-white'}`}>{seconds}s</p>
      </div>

      {/* Question */}
      <div className="absolute left-[22px] w-[358px] top-[204px] flex flex-col items-start gap-[10px]">
        <div className="bg-[rgba(255,255,255,0.12)] rounded-[20px] px-[10px] py-[4px] font-inter font-bold text-[10px] tracking-[0.4px] text-[#d7e4ff]">
          {game.topic}
        </div>
        <p key={index} className="font-inter font-bold text-[21px] leading-[1.28] tracking-[-0.3px] text-white animate-[slide-in_.25s_ease-out]">
          {item.question}
        </p>
      </div>

      {/* Answers */}
      <div className="absolute bg-white bottom-0 h-[494px] left-0 rounded-tl-[23px] rounded-tr-[23px] w-[402px]">
        <div className="absolute left-[24px] top-[24px] w-[354px] flex flex-col gap-[10px]">
          {item.options.map((o, i) => (
            <Option key={`${index}-${i}`} letter={LETTERS[i]} text={o} state={stateFor(i)} pct={poll ? item.results[i] : 0} onClick={() => pick(i)} />
          ))}
          {answered && (
            <div className="mt-[4px] bg-[#eff2fe] rounded-[11px] p-[14px] flex flex-col gap-[4px] animate-[fade_.25s_ease-out]">
              <p className={`font-inter font-bold text-[13px] ${poll || correct ? 'text-[#147f00]' : 'text-[#c62b3b]'}`}>
                {poll ? 'Thanks for sharing! +20 points' : correct ? 'Correct! +50 points' : choice === -1 ? 'Time’s up!' : 'Not quite'}
              </p>
              <p className="font-inter font-medium text-[12px] leading-[1.45] text-[#4f5a6e]">
                {poll ? 'The bars show how other RexPlay players answered.' : item.explain}
              </p>
            </div>
          )}
        </div>
        {answered && (
          <div className="absolute left-[25px] bottom-[34px] w-[351px] animate-[fade_.25s_ease-out]">
            <PrimaryButton onClick={onNext}>{last ? 'See Results' : 'Next Question'}</PrimaryButton>
          </div>
        )}
      </div>
    </>
  );
}

export default function Game({ go, param }) {
  const game = gameById(param) || gameById('naira-savings');
  const { addPlay } = useStore();
  const [phase, setPhase] = useState('intro');
  const [index, setIndex] = useState(0);
  const [score, setScore] = useState(0);
  const [confirm, setConfirm] = useState(false);
  const scoreRef = useRef(0);
  const per = game.kind === 'poll' ? 20 : 50;

  const onAnswer = useRef((ok) => {
    if (ok) {
      scoreRef.current += 1;
      setScore(scoreRef.current);
    }
  }).current;

  const next = () => {
    if (index < game.questions.length - 1) {
      setIndex(index + 1);
      return;
    }
    const points = scoreRef.current * per;
    const { rank } = leaderboard(game, points);
    addPlay({ gameId: game.id, score: scoreRef.current, total: game.questions.length, points, rank });
    go('results', { replace: true });
  };

  return (
    <div className="bg-[#01296a] overflow-clip relative size-full">
      <DarkBackdrop />
      <StatusBar {...DARK_STATUS} />
      <Header title={game.title} onClose={() => setConfirm(true)} />
      {phase === 'intro' ? (
        <Intro game={game} onStart={() => setPhase('play')} />
      ) : (
        <Question key={index} game={game} index={index} points={score * per} onAnswer={onAnswer} onNext={next} />
      )}
      {confirm && <EndGameSheet onCancel={() => setConfirm(false)} onExit={() => go('rexplay', { replace: true })} />}
    </div>
  );
}
