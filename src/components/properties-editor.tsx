
'use client';

import type { AnyControlComponent, ButtonComponent, SliderComponent, ButtonShapeType } from "@/lib/types";
import { BUTTON_SHAPES } from "@/lib/types";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Trash2 } from "lucide-react";

interface PropertiesEditorProps {
  selectedComponent: AnyControlComponent | null;
  onUpdateComponent: (component: AnyControlComponent) => void;
  onDeleteComponent: (componentId: string) => void;
}

export function PropertiesEditor({ selectedComponent, onUpdateComponent, onDeleteComponent }: PropertiesEditorProps) {
  if (!selectedComponent) {
    return (
      <Card className="shadow-md h-full">
        <CardHeader>
          <CardTitle className="text-base md:text-lg">Properties</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground">Select a component to edit its properties.</p>
        </CardContent>
      </Card>
    );
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value, type } = e.target;
    let processedValue: string | number = value;
    if (type === 'number' || name === 'outputIndex' || name === 'min' || name === 'max' || name.startsWith('position.') || name.startsWith('size.')) {
      processedValue = parseFloat(value);
      if (isNaN(processedValue)) processedValue = 0;
    }
    
    const keys = name.split('.');
    if (keys.length > 1) {
      onUpdateComponent({
        ...selectedComponent,
        [keys[0]]: { ...(selectedComponent[keys[0] as keyof AnyControlComponent] as object), [keys[1]]: processedValue },
      } as AnyControlComponent);
    } else {
      onUpdateComponent({ ...selectedComponent, [name]: processedValue });
    }
  };
  
  const handleSelectChange = (name: string, value: string) => {
     onUpdateComponent({ ...selectedComponent, [name]: value } as AnyControlComponent);
  };

  const commonFields = (
    <>
      <div className="space-y-1">
        <Label htmlFor="label">Label</Label>
        <Input id="label" name="label" value={selectedComponent.label} onChange={handleInputChange} />
      </div>
      <div className="space-y-1">
        <Label htmlFor="outputIndex">Output Index</Label>
        <Input id="outputIndex" name="outputIndex" type="number" value={selectedComponent.outputIndex} onChange={handleInputChange} />
      </div>
      <div className="grid grid-cols-2 gap-2">
        <div className="space-y-1">
          <Label htmlFor="position.x">Position X</Label>
          <Input id="position.x" name="position.x" type="number" value={selectedComponent.position.x} onChange={handleInputChange} />
        </div>
        <div className="space-y-1">
          <Label htmlFor="position.y">Position Y</Label>
          <Input id="position.y" name="position.y" type="number" value={selectedComponent.position.y} onChange={handleInputChange} />
        </div>
      </div>
      <div className="grid grid-cols-2 gap-2">
        <div className="space-y-1">
          <Label htmlFor="size.width">Width</Label>
          <Input id="size.width" name="size.width" type="number" value={selectedComponent.size.width} onChange={handleInputChange} />
        </div>
        <div className="space-y-1">
          <Label htmlFor="size.height">Height</Label>
          <Input id="size.height" name="size.height" type="number" value={selectedComponent.size.height} onChange={handleInputChange} />
        </div>
      </div>
    </>
  );

  return (
    <Card className="shadow-md">
      <CardHeader>
        <div className="flex justify-between items-center">
          <div>
            <CardTitle className="text-base md:text-lg capitalize">{selectedComponent.type} Properties</CardTitle>
            <CardDescription className="text-xs sm:text-sm">{selectedComponent.label}</CardDescription>
          </div>
          <Button variant="destructive" size="icon" onClick={() => onDeleteComponent(selectedComponent.id)} aria-label="Delete component" className="rounded-full">
            <Trash2 size={18} />
          </Button>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {commonFields}
        {selectedComponent.type === 'button' && (
          <>
            <div className="space-y-1">
              <Label htmlFor="mode">Mode</Label>
              <Select name="mode" value={(selectedComponent as ButtonComponent).mode} onValueChange={(value) => handleSelectChange('mode', value)}>
                <SelectTrigger>
                  <SelectValue placeholder="Select mode" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="momentary">Momentary</SelectItem>
                  <SelectItem value="toggle">Toggle</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-1">
              <Label htmlFor="shape">Shape</Label>
              <Select name="shape" value={(selectedComponent as ButtonComponent).shape || 'default'} onValueChange={(value) => handleSelectChange('shape', value as ButtonShapeType)}>
                <SelectTrigger>
                  <SelectValue placeholder="Select shape" />
                </SelectTrigger>
                <SelectContent>
                  {BUTTON_SHAPES.map(shape => (
                    <SelectItem key={shape.value} value={shape.value}>{shape.label}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </>
        )}
        {selectedComponent.type === 'slider' && (
          <>
            <div className="space-y-1">
              <Label htmlFor="orientation">Orientation</Label>
              <Select name="orientation" value={(selectedComponent as SliderComponent).orientation} onValueChange={(value) => handleSelectChange('orientation', value)}>
                <SelectTrigger>
                  <SelectValue placeholder="Select orientation" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="horizontal">Horizontal</SelectItem>
                  <SelectItem value="vertical">Vertical</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="grid grid-cols-2 gap-2">
              <div className="space-y-1">
                <Label htmlFor="min">Min Value</Label>
                <Input id="min" name="min" type="number" value={(selectedComponent as SliderComponent).min} onChange={handleInputChange} />
              </div>
              <div className="space-y-1">
                <Label htmlFor="max">Max Value</Label>
                <Input id="max" name="max" type="number" value={(selectedComponent as SliderComponent).max} onChange={handleInputChange} />
              </div>
            </div>
             <div className="space-y-1">
                <Label htmlFor="defaultValue">Default Value</Label>
                <Input id="defaultValue" name="defaultValue" type="number" value={(selectedComponent as SliderComponent).defaultValue} onChange={handleInputChange} />
              </div>
          </>
        )}
        {/* Add specific fields for Joystick and DPad as needed */}
      </CardContent>
    </Card>
  );
}
