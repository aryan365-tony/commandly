
'use client';

import type { SliderComponent } from '@/lib/types';
import { Slider as ShadSlider } from '@/components/ui/slider';
import { Label } from '@/components/ui/label';
import { useState, useEffect } from 'react';

interface RuntimeSliderProps {
  component: SliderComponent;
  onStateChange: (id: string, value: number) => void;
}

export function RuntimeSlider({ component, onStateChange }: RuntimeSliderProps) {
  const [currentValue, setCurrentValue] = useState(component.defaultValue ?? component.min);

  useEffect(() => {
    const initialValue = component.defaultValue ?? component.min;
    setCurrentValue(initialValue);
    onStateChange(component.id, initialValue);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [component]); // Re-initialize if component definition changes

  const handleValueChange = (value: number[]) => {
    const val = value[0];
    setCurrentValue(val);
    onStateChange(component.id, val);
  };

  return (
    <div
      style={{
        position: 'absolute',
        left: `${component.position.x}px`,
        top: `${component.position.y}px`,
        width: `${component.size.width}px`,
        height: `${component.size.height}px`,
        display: 'flex',
        flexDirection: component.orientation === 'vertical' ? 'column' : 'row',
        alignItems: 'center',
        padding: '4px 8px', // Reduced padding slightly
        boxSizing: 'border-box',
      }}
      className="bg-card border border-border rounded-md shadow"
    >
      <Label htmlFor={component.id} className="text-[10px] sm:text-xs text-muted-foreground mb-0.5 sm:mb-1 mr-1 sm:mr-2 truncate">
        {component.label}: {currentValue}
      </Label>
      <ShadSlider
        id={component.id}
        min={component.min}
        max={component.max}
        step={1}
        defaultValue={[currentValue]}
        onValueChange={handleValueChange}
        orientation={component.orientation}
        className={component.orientation === 'vertical' ? 'h-full w-auto' : 'w-full h-auto'}
      />
    </div>
  );
}
