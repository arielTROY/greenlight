import React, {
  createContext,
  useContext,
  useEffect,
  useRef,
  useState,
  ReactNode,
} from 'react';

type Direction = 'up' | 'down' | 'left' | 'right';
type GamepadNavContextType = {
  setActiveGroup: (groupId: string) => void;
  activeGroup: string;
};

const GamepadNavigationContext = createContext<GamepadNavContextType>({
  activeGroup: 'default',
  setActiveGroup: () => {},
});

export const GamepadNavigationProvider = ({ children }: { children: ReactNode }) => {
  const [activeGroup, setActiveGroupState] = useState('default');
  const prevButtons = useRef<boolean[]>([]);

  // 🧠 Move focus in a direction
  const moveFocus = (direction: Direction) => {
    const current = document.activeElement as HTMLElement;
    const isValidElement = current?.hasAttribute?.('data-nav');
  
    // 🧠 If no valid focus, fallback to first in group
    if (!isValidElement) {
      const first = document.querySelector<HTMLElement>(
        `[data-nav][data-nav-group="${activeGroup}"]`
      );
      first?.focus();
      return;
    }
  
    const currentRect = current.getBoundingClientRect();
    const elements = Array.from(
      document.querySelectorAll<HTMLElement>('[data-nav]')
    ).filter(
      (el) =>
        el.tabIndex >= 0 &&
        (el.getAttribute('data-nav-group') || 'default') === activeGroup
    );
  
    let best: HTMLElement | null = null;
    let bestDistance = Infinity;
  
    for (const el of elements) {
      if (el === current) continue;
      const rect = el.getBoundingClientRect();
  
      const isValid = {
        up: rect.bottom <= currentRect.top,
        down: rect.top >= currentRect.bottom,
        left: rect.right <= currentRect.left,
        right: rect.left >= currentRect.right,
      }[direction];
  
      if (!isValid) continue;
  
      const dx = rect.left - currentRect.left;
      const dy = rect.top - currentRect.top;
      const distance = Math.sqrt(dx * dx + dy * dy);
  
      if (distance < bestDistance) {
        best = el;
        bestDistance = distance;
      }
    }
  
    if (best) {
      best.focus();
      best.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'nearest' });
    }
  };  

  // 🔘 Simulate enter/click
  const handleAction = () => {
    const current = document.activeElement as HTMLElement;
    current?.click?.();
  };

  // 🎮 Gamepad polling
  useEffect(() => {
    const pollGamepad = () => {
      const gamepads = navigator.getGamepads();
      const gp = gamepads[0];
      if (!gp) return;

      const buttons = gp.buttons.map((btn) => btn.pressed);
      const wasPressed = (i: number) => buttons[i] && !prevButtons.current[i];

      if (wasPressed(12)) moveFocus('up');
      if (wasPressed(13)) moveFocus('down');
      if (wasPressed(14)) moveFocus('left');
      if (wasPressed(15)) moveFocus('right');
      if (wasPressed(0)) handleAction(); // A
      if (wasPressed(1)) setActiveGroup('default'); // B

      prevButtons.current = buttons;
    };

    const interval = setInterval(pollGamepad, 100);
    return () => clearInterval(interval);
  }, [activeGroup]);

  // ⌨️ Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      switch (e.key) {
        case 'ArrowUp':
          e.preventDefault();
          moveFocus('up');
          break;
        case 'ArrowDown':
          e.preventDefault();
          moveFocus('down');
          break;
        case 'ArrowLeft':
          e.preventDefault();
          moveFocus('left');
          break;
        case 'ArrowRight':
          e.preventDefault();
          moveFocus('right');
          break;
        case 'Enter':
          handleAction();
          break;
        case 'Escape':
          setActiveGroup('default');
          break;
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [activeGroup]);

  // 🚀 Auto-focus first item in group
  const setActiveGroup = (groupId: string) => {
    setActiveGroupState(groupId);

    setTimeout(() => {
      const first = document.querySelector<HTMLElement>(
        `[data-nav][data-nav-group="${groupId}"]`
      );
      if (first) {
        first.focus();
        first.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      }
    }, 0); // Wait for DOM/layout updates if needed
  };

  return (
    <GamepadNavigationContext.Provider value={{ setActiveGroup, activeGroup }}>
      {children}
    </GamepadNavigationContext.Provider>
  );
};

export const useGamepadNavigation = () => useContext(GamepadNavigationContext);
