
'use client';

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import type { ControlComponentType } from "@/lib/types";
import { MousePointerClick, SlidersHorizontal, Gamepad2, Grid } from 'lucide-react';

interface ControlPaletteProps {
  onAddComponent: (type: ControlComponentType) => void;
}

const controlTypes: { type: ControlComponentType; label: string; icon: React.ElementType }[] = [
  { type: 'button', label: 'Button', icon: MousePointerClick },
  { type: 'slider', label: 'Slider', icon: SlidersHorizontal },
  { type: 'joystick', label: 'Joystick', icon: Gamepad2 },
  { type: 'dpad', label: 'D-Pad', icon: Grid },
];

export function ControlPalette({ onAddComponent }: ControlPaletteProps) {
  return (
    <Card className="shadow-md">
      <CardHeader>
        <CardTitle className="text-base md:text-lg">Add Controls</CardTitle>
      </CardHeader>
      <CardContent className="grid grid-cols-2 gap-3 sm:gap-4">
        {controlTypes.map(({ type, label, icon: Icon }) => (
          <Button
            key={type}
            variant="outline"
            className="flex flex-col items-center justify-center w-20 h-20 sm:w-24 sm:h-24 p-2 text-center rounded-full hover:bg-accent hover:text-accent-foreground aspect-square"
            onClick={() => onAddComponent(type)}
          >
            <Icon size={20} className="mb-1 sm:mb-2 sm:size-24" />
            <span className="text-[10px] sm:text-xs">{label}</span>
          </Button>
        ))}
      </CardContent>
    </Card>
  );
}
