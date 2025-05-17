
'use client';

import type { DPadComponent } from '@/lib/types';
import { ArrowUp, ArrowDown, ArrowLeft, ArrowRight } from 'lucide-react';
import { useState, useEffect } from 'react';

interface RuntimeDPadProps {
  component: DPadComponent;
  onStateChange: (id: string, value: { up: number; down: number; left: number; right: number }) => void;
  // Output: 1 for pressed, 0 for released for each direction
}

export function RuntimeDPad({ component, onStateChange }: RuntimeDPadProps) {
  const [dPadState, setDPadState] = useState({ up: 0, down: 0, left: 0, right: 0 });

  const handlePress = (direction: keyof typeof dPadState) => {
    const newState = { ...dPadState, [direction]: 1 };
    setDPadState(newState);
    onStateChange(component.id, newState);
  };

  const handleRelease = (direction: keyof typeof dPadState) => {
    const newState = { ...dPadState, [direction]: 0 };
    setDPadState(newState);
    onStateChange(component.id, newState);
  };
  
  useEffect(() => {
    // Reset state if component definition changes (though unlikely for DPad fixed structure)
    const initial = { up: 0, down: 0, left: 0, right: 0 };
    setDPadState(initial);
    onStateChange(component.id, initial);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [component]);

  const buttonBaseClass = "absolute bg-card hover:bg-muted border border-border rounded-md flex items-center justify-center transition-colors duration-150 select-none";
  const activeClass = "!bg-primary text-primary-foreground ring-2 ring-primary ring-offset-2";

  const buttonSize = Math.min(component.size.width, component.size.height) * 0.3; // Each D-Pad button is ~30% of component size
  const offset = buttonSize * 0.1; // Small offset for better visual separation

  return (
    <div
      style={{
        position: 'absolute',
        left: `${component.position.x}px`,
        top: `${component.position.y}px`,
        width: `${component.size.width}px`,
        height: `${component.size.height}px`,
      }}
      className="relative"
      title={component.label}
    >
      {/* Up Button */}
      <button
        style={{
          width: `${buttonSize}px`,
          height: `${buttonSize}px`,
          top: `${component.size.height / 2 - buttonSize * 1.5 - offset}px`,
          left: `${component.size.width / 2 - buttonSize / 2}px`,
        }}
        className={`${buttonBaseClass} ${dPadState.up ? activeClass : ''}`}
        onMouseDown={() => handlePress('up')}
        onMouseUp={() => handleRelease('up')}
        onTouchStart={() => handlePress('up')}
        onTouchEnd={() => handleRelease('up')}
        aria-label={`${component.label} Up`}
        aria-pressed={!!dPadState.up}
      >
        <ArrowUp size={buttonSize * 0.6} />
      </button>

      {/* Down Button */}
      <button
        style={{
          width: `${buttonSize}px`,
          height: `${buttonSize}px`,
          top: `${component.size.height / 2 + buttonSize * 0.5 + offset}px`,
          left: `${component.size.width / 2 - buttonSize / 2}px`,
        }}
        className={`${buttonBaseClass} ${dPadState.down ? activeClass : ''}`}
        onMouseDown={() => handlePress('down')}
        onMouseUp={() => handleRelease('down')}
        onTouchStart={() => handlePress('down')}
        onTouchEnd={() => handleRelease('down')}
        aria-label={`${component.label} Down`}
        aria-pressed={!!dPadState.down}
      >
        <ArrowDown size={buttonSize * 0.6} />
      </button>

      {/* Left Button */}
      <button
        style={{
          width: `${buttonSize}px`,
          height: `${buttonSize}px`,
          top: `${component.size.height / 2 - buttonSize / 2}px`,
          left: `${component.size.width / 2 - buttonSize * 1.5 - offset}px`,
        }}
        className={`${buttonBaseClass} ${dPadState.left ? activeClass : ''}`}
        onMouseDown={() => handlePress('left')}
        onMouseUp={() => handleRelease('left')}
        onTouchStart={() => handlePress('left')}
        onTouchEnd={() => handleRelease('left')}
        aria-label={`${component.label} Left`}
        aria-pressed={!!dPadState.left}
      >
        <ArrowLeft size={buttonSize * 0.6} />
      </button>

      {/* Right Button */}
      <button
        style={{
          width: `${buttonSize}px`,
          height: `${buttonSize}px`,
          top: `${component.size.height / 2 - buttonSize / 2}px`,
          left: `${component.size.width / 2 + buttonSize * 0.5 + offset}px`,
        }}
        className={`${buttonBaseClass} ${dPadState.right ? activeClass : ''}`}
        onMouseDown={() => handlePress('right')}
        onMouseUp={() => handleRelease('right')}
        onTouchStart={() => handlePress('right')}
        onTouchEnd={() => handleRelease('right')}
        aria-label={`${component.label} Right`}
        aria-pressed={!!dPadState.right}
      >
        <ArrowRight size={buttonSize * 0.6} />
      </button>
      
      {/* Center piece (optional, non-interactive) */}
      <div
        style={{
          width: `${buttonSize * 0.8}px`,
          height: `${buttonSize * 0.8}px`,
          top: `${component.size.height / 2 - buttonSize * 0.4}px`,
          left: `${component.size.width / 2 - buttonSize * 0.4}px`,
        }}
        className="absolute bg-muted border border-border rounded-sm pointer-events-none"
      ></div>
    </div>
  );
}
