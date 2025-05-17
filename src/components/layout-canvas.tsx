
'use client';

import type { AnyControlComponent, ButtonComponent, SliderComponent, JoystickComponent, DPadComponent } from "@/lib/types";
import { Card, CardContent } from "@/components/ui/card";
import { Slider } from "@/components/ui/slider";
import { Move, Maximize, GripHorizontal } from "lucide-react"; 
import { cn } from "@/lib/utils";

interface LayoutCanvasProps {
  components: AnyControlComponent[];
  onSelectComponent: (component: AnyControlComponent) => void;
  selectedComponentId?: string | null;
}

const renderComponent = (
  component: AnyControlComponent, 
  isSelected: boolean,
  onSelect: () => void
) => {
  const key = component.id; 
  let shapeClass = 'rounded-md'; 
  if (component.type === 'button') {
    const buttonComp = component as ButtonComponent;
    switch (buttonComp.shape) {
      case 'pill':
      case 'circle': 
        shapeClass = 'rounded-full';
        break;
      case 'sharp':
        shapeClass = 'rounded-none';
        break;
      case 'default':
      default:
        shapeClass = 'rounded-md';
        break;
    }
  } else if (component.type === 'joystick') {
    shapeClass = 'rounded-full';
  }

  const baseStyle: React.CSSProperties = {
    position: 'absolute',
    left: `${component.position.x}px`,
    top: `${component.position.y}px`,
    width: `${component.size.width}px`,
    height: `${component.size.height}px`,
    border: isSelected ? '2px solid hsl(var(--ring))' : '1px solid hsl(var(--border))',
    boxShadow: isSelected ? '0 0 0 2px hsl(var(--background)), 0 0 0 4px hsl(var(--ring))' : 'none',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    cursor: 'grab', 
    overflow: 'hidden', 
    backgroundColor: 'hsl(var(--card))'
  };

  const commonProps = {
    style: baseStyle,
    onClick: (e: React.MouseEvent) => { 
      e.stopPropagation(); 
      onSelect();
    },
    className: cn(
      `p-1 transition-all duration-150 ease-in-out transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2`, // Reduced padding
      shapeClass
    ),
    title: component.label,
    'aria-label': component.label,
  };

  switch (component.type) {
    case 'button':
      return (
        <div key={key} {...commonProps} role="button" tabIndex={0}>
          <span className="truncate text-[10px] sm:text-xs text-card-foreground">{component.label}</span>
        </div>
      );
    case 'slider':
      const sliderComp = component as SliderComponent;
      return (
        <div key={key} {...commonProps}>
          <div className="flex flex-col items-center w-full h-full justify-center p-1">
            <span className="text-[9px] sm:text-[10px] text-muted-foreground truncate mb-0.5 sm:mb-1">{component.label}</span>
            {sliderComp.orientation === 'horizontal' ? (
              <Slider defaultValue={[sliderComp.defaultValue ?? 50]} min={sliderComp.min} max={sliderComp.max} className="w-full" />
            ) : (
              <Slider defaultValue={[sliderComp.defaultValue ?? 50]} min={sliderComp.min} max={sliderComp.max} orientation="vertical" className="h-full" />
            )}
          </div>
        </div>
      );
    case 'joystick':
      return (
        <div key={key} {...commonProps}>
          <Move size={Math.min(component.size.width, component.size.height) * 0.4} className="text-muted-foreground" /> {/* Slightly smaller icon */}
        </div>
      );
    case 'dpad':
      return (
        <div key={key} {...commonProps} >
           <GripHorizontal size={Math.min(component.size.width, component.size.height) * 0.4} className="text-muted-foreground" />  {/* Slightly smaller icon */}
        </div>
      );
    default:
      return <div key={key} {...commonProps} className="text-xs">Unsupported</div>;
  }
};


export function LayoutCanvas({ components, onSelectComponent, selectedComponentId }: LayoutCanvasProps) {
  const handleCanvasClick = () => {
    // onSelectComponent(null); 
  };

  return (
    <div 
      className="relative w-full h-full" 
      onClick={handleCanvasClick}
      aria-label="Layout design canvas grid"
    >
      {components.length === 0 && (
        <div className="absolute inset-0 flex flex-col items-center justify-center text-muted-foreground p-4 text-center">
          <Maximize size={32} className="mb-2 sm:size-48 sm:mb-4" />
          <p className="text-xs sm:text-sm">Add components from the palette.</p>
          <p className="text-[10px] sm:text-xs">(Drag and drop coming soon!)</p>
        </div>
      )}
      {components.map(comp => 
        renderComponent(comp, comp.id === selectedComponentId, () => onSelectComponent(comp))
      )}
    </div>
  );
}
