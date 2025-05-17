
'use client';

import type { JoystickComponent } from '@/lib/types';
import { Move } from 'lucide-react';
import { useState, useRef, useEffect } from 'react';

interface RuntimeJoystickProps {
  component: JoystickComponent;
  onStateChange: (id: string, value: { x: number; y: number }) => void; // x, y typically -1 to 1 or 0-255
}

const JOYSTICK_CENTER_VALUE = 128; // Assuming output range 0-255 for axes
const JOYSTICK_MAX_OFFSET = 127;

export function RuntimeJoystick({ component, onStateChange }: RuntimeJoystickProps) {
  const [position, setPosition] = useState({ x: JOYSTICK_CENTER_VALUE, y: JOYSTICK_CENTER_VALUE });
  const [isDragging, setIsDragging] = useState(false);
  const joystickRef = useRef<HTMLDivElement>(null);
  const knobRef = useRef<HTMLDivElement>(null);

  const calculateJoystickValues = (dx: number, dy: number, radius: number) => {
    const distance = Math.sqrt(dx * dx + dy * dy);
    let newX = 0, newY = 0;

    if (distance > radius) {
      newX = (dx / distance) * radius;
      newY = (dy / distance) * radius;
    } else {
      newX = dx;
      newY = dy;
    }
    
    // Normalize to output range (e.g., 0-255)
    // Assuming (0,0) is center for calculation, then map to output
    const outputX = Math.round(JOYSTICK_CENTER_VALUE + (newX / radius) * JOYSTICK_MAX_OFFSET);
    const outputY = Math.round(JOYSTICK_CENTER_VALUE - (newY / radius) * JOYSTICK_MAX_OFFSET); // Y is often inverted

    return { knobX: newX, knobY: newY, outputX, outputY };
  };
  
  const handleMove = (clientX: number, clientY: number, currentJoystickRef: HTMLDivElement | null) => {
    if (!currentJoystickRef) return;

    const rect = currentJoystickRef.getBoundingClientRect();
    const knobElement = knobRef.current;
    const knobRadius = knobElement ? knobElement.offsetWidth / 2 : rect.width * 0.2 / 2;
    const radius = rect.width / 2 - knobRadius;
    
    const dx = clientX - (rect.left + rect.width / 2);
    const dy = clientY - (rect.top + rect.height / 2);

    const { knobX, knobY, outputX, outputY } = calculateJoystickValues(dx, dy, radius);

    if (knobRef.current) {
      knobRef.current.style.transform = `translate(${knobX}px, ${knobY}px)`;
    }
    setPosition({ x: outputX, y: outputY });
    onStateChange(component.id, { x: outputX, y: outputY });
  };

  const handleStart = (e: React.MouseEvent | React.TouchEvent) => {
    setIsDragging(true);
    // For touch, prevent page scroll
    if ('touches' in e) {
      e.preventDefault();
    }
  };

  const handleEnd = () => {
    if (!isDragging) return;
    setIsDragging(false);
    if (knobRef.current) {
      knobRef.current.style.transform = 'translate(0px, 0px)';
    }
    setPosition({ x: JOYSTICK_CENTER_VALUE, y: JOYSTICK_CENTER_VALUE });
    onStateChange(component.id, { x: JOYSTICK_CENTER_VALUE, y: JOYSTICK_CENTER_VALUE });
  };
  
  useEffect(() => {
    const currentJoystickRef = joystickRef.current;
    
    const onMouseMove = (e: MouseEvent) => {
      if (isDragging && currentJoystickRef) handleMove(e.clientX, e.clientY, currentJoystickRef);
    };
    const onTouchMove = (e: TouchEvent) => {
      if (isDragging && e.touches[0] && currentJoystickRef) {
        e.preventDefault(); // Prevent scrolling while dragging
        handleMove(e.touches[0].clientX, e.touches[0].clientY, currentJoystickRef);
      }
    };

    if (isDragging) {
      document.addEventListener('mousemove', onMouseMove);
      document.addEventListener('mouseup', handleEnd);
      document.addEventListener('touchmove', onTouchMove, { passive: false });
      document.addEventListener('touchend', handleEnd);
    }

    return () => {
      document.removeEventListener('mousemove', onMouseMove);
      document.removeEventListener('mouseup', handleEnd);
      document.removeEventListener('touchmove', onTouchMove);
      document.removeEventListener('touchend', handleEnd);
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isDragging, component.id]);


  const joystickBaseStyle: React.CSSProperties = {
    width: `${component.size.width}px`,
    height: `${component.size.height}px`,
    borderRadius: '50%',
    backgroundColor: 'hsl(var(--muted))',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
    cursor: 'grab',
    userSelect: 'none',
    boxShadow: 'inset 0 0 10px rgba(0,0,0,0.2)',
  };

  const knobSize = Math.min(component.size.width, component.size.height) * 0.4;
  const joystickKnobStyle: React.CSSProperties = {
    width: `${knobSize}px`,
    height: `${knobSize}px`,
    borderRadius: '50%',
    backgroundColor: 'hsl(var(--primary))',
    position: 'absolute',
    cursor: 'grabbing',
    transition: isDragging ? 'none' : 'transform 0.1s ease-out',
    boxShadow: '0 2px 5px rgba(0,0,0,0.3)',
  };
  
  const joystickContent = (
    <div
      ref={joystickRef}
      style={joystickBaseStyle}
      onMouseDown={handleStart}
      onTouchStart={handleStart}
      role="slider"
      aria-valuemin={0}
      aria-valuemax={255}
      aria-valuenow={position.x} 
      aria-label={`${component.label} Joystick`}
    >
      <div ref={knobRef} style={joystickKnobStyle}></div>
       <Move 
            size={Math.min(component.size.width, component.size.height) * 0.2} 
            className="absolute opacity-20 pointer-events-none"
        />
    </div>
  );
  
  return (
    <div
      style={{
        position: 'absolute',
        left: `${component.position.x}px`,
        top: `${component.position.y}px`,
        width: `${component.size.width}px`,
        height: `${component.size.height}px`,
      }}
      title={component.label}
    >
      {joystickContent}
    </div>
  );
}

