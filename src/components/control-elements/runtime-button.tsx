
'use client';

import type { ButtonComponent } from '@/lib/types';
import { Button as ShadButton } from '@/components/ui/button'; // Renaming to avoid conflict
import { useState, useEffect } from 'react';
import { cn } from '@/lib/utils';

interface RuntimeButtonProps {
  component: ButtonComponent;
  onStateChange: (id: string, value: number) => void; // 0 for off, 1 for on
}

export function RuntimeButton({ component, onStateChange }: RuntimeButtonProps) {
  const [isActive, setIsActive] = useState(false);

  const handleClick = () => {
    if (component.mode === 'momentary') {
      // For momentary, it's handled by onMouseDown/onMouseUp or onTouchStart/onTouchEnd
      // This basic version will just send a single "on" then "off" for click
      onStateChange(component.id, 1);
      setTimeout(() => onStateChange(component.id, 0), 100); // Simulate release
    } else { // toggle
      const newState = !isActive;
      setIsActive(newState);
      onStateChange(component.id, newState ? 1 : 0);
    }
  };

  const handlePress = () => {
    if (component.mode === 'momentary') {
      setIsActive(true);
      onStateChange(component.id, 1);
    }
  };

  const handleRelease = () => {
    if (component.mode === 'momentary') {
      setIsActive(false);
      onStateChange(component.id, 0);
    }
  };
  
  // Update internal state if component definition changes (e.g. mode)
  useEffect(() => {
    setIsActive(false); // Reset on component change
    // Ensure consistent state update when component definition might change externally
    onStateChange(component.id, 0); 
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [component.id, component.mode]); // Depend on id and mode

  const shapeClasses = {
    default: 'rounded-md',
    pill: 'rounded-full',
    circle: 'rounded-full', 
    sharp: 'rounded-none',
  };
  const currentShapeClass = shapeClasses[component.shape || 'default'] || shapeClasses.default;
  
  // Ensure circle buttons are truly circular by aspect ratio if w=h
  const aspectSquareClass = component.shape === 'circle' && component.size.width === component.size.height ? 'aspect-square' : '';

  return (
    <ShadButton
      style={{
        position: 'absolute',
        left: `${component.position.x}px`,
        top: `${component.position.y}px`,
        width: `${component.size.width}px`,
        height: `${component.size.height}px`,
      }}
      variant={isActive ? "default" : "outline"}
      className={cn(
        'text-[10px] sm:text-xs md:text-sm transition-colors duration-100 select-none p-1 leading-tight', // Adjusted padding and leading
        isActive ? 'ring-2 ring-primary ring-offset-2' : '',
        currentShapeClass,
        aspectSquareClass
      )}
      onClick={component.mode === 'toggle' ? handleClick : undefined}
      onMouseDown={component.mode === 'momentary' ? handlePress : undefined}
      onMouseUp={component.mode === 'momentary' ? handleRelease : undefined}
      onTouchStart={component.mode === 'momentary' ? handlePress : undefined}
      onTouchEnd={component.mode === 'momentary' ? handleRelease : undefined}
      aria-pressed={isActive}
    >
      {component.label}
    </ShadButton>
  );
}
