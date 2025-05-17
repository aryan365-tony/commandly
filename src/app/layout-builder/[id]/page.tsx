
'use client';

import { useEffect, useState, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import type { Layout, AnyControlComponent, CommunicationSettings, ControlComponentType } from '@/lib/types';
import { getDefaultControlComponent, getDefaultCommunicationSettings } from '@/lib/types';
import { getLayoutById, saveLayout, createNewLayout } from '@/lib/layouts';
import { ControlPalette } from '@/components/control-palette';
import { PropertiesEditor } from '@/components/properties-editor';
import { LayoutCanvas } from '@/components/layout-canvas';
import { CommunicationSettingsForm } from '@/components/communication-settings-form';
import { useToast } from "@/hooks/use-toast";
import { ArrowLeft, Save } from 'lucide-react';
import { cn } from '@/lib/utils';

export default function LayoutBuilderPage() {
  const params = useParams();
  const router = useRouter();
  const { toast } = useToast();
  
  const layoutId = params.id as string;
  const isNewLayout = layoutId === 'new';

  const [layout, setLayout] = useState<Layout | null>(null);
  const [selectedComponent, setSelectedComponent] = useState<AnyControlComponent | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (isNewLayout) {
      setLayout(createNewLayout());
      setIsLoading(false);
    } else {
      const existingLayout = getLayoutById(layoutId);
      if (existingLayout) {
        setLayout(existingLayout);
      } else {
        toast({ title: "Error", description: "Layout not found.", variant: "destructive" });
        router.push('/'); // Redirect if layout not found
      }
      setIsLoading(false);
    }
  }, [layoutId, isNewLayout, router, toast]);

  const handleLayoutNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (layout) {
      setLayout({ ...layout, name: e.target.value });
    }
  };

  const handleAddComponent = useCallback((type: ControlComponentType) => {
    if (!layout) return;
    const newComponentId = `comp_${new Date().getTime()}_${Math.random().toString(36).substring(2, 7)}`;
    const newComponent = getDefaultControlComponent(type, newComponentId, layout.components.length);
    setLayout(prevLayout => prevLayout ? { ...prevLayout, components: [...prevLayout.components, newComponent] } : null);
    setSelectedComponent(newComponent);
  }, [layout]);

  const handleUpdateComponent = useCallback((updatedComponent: AnyControlComponent) => {
    if (!layout) return;
    setLayout(prevLayout => 
      prevLayout ? {
        ...prevLayout,
        components: prevLayout.components.map(c => c.id === updatedComponent.id ? updatedComponent : c),
      } : null
    );
    if (selectedComponent?.id === updatedComponent.id) {
      setSelectedComponent(updatedComponent);
    }
  }, [layout, selectedComponent]);
  
  const handleDeleteComponent = useCallback((componentId: string) => {
    if (!layout) return;
    setLayout(prevLayout => 
      prevLayout ? {
        ...prevLayout,
        components: prevLayout.components.filter(c => c.id !== componentId),
      } : null
    );
    if (selectedComponent?.id === componentId) {
      setSelectedComponent(null);
    }
    toast({ title: "Component Deleted", description: "The component has been removed from the layout." });
  }, [layout, selectedComponent, toast]);


  const handleCommunicationSettingsChange = (settings: CommunicationSettings) => {
    if (layout) {
      setLayout({ ...layout, communicationSettings: settings });
    }
  };

  const handleSaveLayout = () => {
    if (layout && layout.name.trim() !== "") {
      saveLayout(layout);
      toast({
        title: "Layout Saved!",
        description: `Layout "${layout.name}" has been saved successfully.`,
      });
      router.push('/');
    } else {
      toast({
        title: "Error Saving",
        description: "Layout name cannot be empty.",
        variant: "destructive",
      });
    }
  };

  if (isLoading || !layout) {
    return <div className="text-center py-10 text-sm sm:text-base">Loading layout builder...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <Button variant="outline" size="sm" asChild>
          <Link href="/">
            <ArrowLeft size={16} className="mr-2" /> Back
          </Link>
        </Button>
        <h1 className="text-lg sm:text-xl md:text-2xl font-bold text-center truncate px-2">
          {isNewLayout ? 'Create New Layout' : `Edit: ${layout.name}`}
        </h1>
        <Button onClick={handleSaveLayout} size="lg">
          <Save size={20} className="mr-2" /> Save
        </Button>
      </div>

      <Card>
        <CardHeader className="py-3 px-4">
          <CardTitle className="text-base md:text-lg">Layout Name</CardTitle>
        </CardHeader>
        <CardContent className="p-4">
          <Input
            type="text"
            value={layout.name}
            onChange={handleLayoutNameChange}
            placeholder="Enter layout name"
            className="text-sm md:text-base"
          />
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
           <Card className="shadow-lg">
            <CardContent 
              className={cn(
                "relative controller-canvas-bg rounded-lg overflow-auto p-4 border-2 border-dashed border-muted-foreground/20",
                "h-[calc(100vw*0.75)] max-h-[600px] md:h-[600px] w-full" 
              )}
              aria-label="Layout design canvas"
            >
              <LayoutCanvas 
                components={layout.components} 
                onSelectComponent={setSelectedComponent} 
                selectedComponentId={selectedComponent?.id} 
              />
            </CardContent>
          </Card>
        </div>
        <div className="space-y-6">
          <ControlPalette onAddComponent={handleAddComponent} />
          <PropertiesEditor 
            selectedComponent={selectedComponent} 
            onUpdateComponent={handleUpdateComponent}
            onDeleteComponent={handleDeleteComponent}
          />
        </div>
      </div>
      
      <CommunicationSettingsForm 
        settings={layout.communicationSettings} 
        onSettingsChange={handleCommunicationSettingsChange} 
      />

    </div>
  );
}
