
'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { LayoutCard } from '@/components/layout-card';
import type { Layout } from '@/lib/types';
import { getLayouts, deleteLayout as deleteLayoutFromStorage } from '@/lib/layouts';
import { PlusCircle, LayoutGrid } from 'lucide-react';
import { useToast } from "@/hooks/use-toast";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";

export default function HomePage() {
  const [layouts, setLayouts] = useState<Layout[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const { toast } = useToast();

  useEffect(() => {
    setLayouts(getLayouts());
    setIsLoading(false);
  }, []);

  const handleDeleteLayout = (id: string) => {
    deleteLayoutFromStorage(id);
    setLayouts(getLayouts()); // Refresh layouts from storage
    toast({
      title: "Layout Deleted",
      description: "The layout has been successfully deleted.",
    });
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LayoutGrid className="h-10 w-10 sm:h-12 sm:w-12 animate-spin text-primary" />
        <p className="ml-4 text-base sm:text-lg">Loading layouts...</p>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl sm:text-3xl font-bold">Layout Manager</h1>
        <TooltipProvider>
          <Tooltip>
            <TooltipTrigger asChild>
              <Button asChild size="icon" className="rounded-full w-12 h-12">
                <Link href="/layout-builder/new">
                  <PlusCircle size={24} />
                  <span className="sr-only">Create New Layout</span>
                </Link>
              </Button>
            </TooltipTrigger>
            <TooltipContent>
              <p>Create New Layout</p>
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>
      </div>

      {layouts.length === 0 ? (
        <div className="text-center py-10 border-2 border-dashed border-muted-foreground/30 rounded-lg">
          <LayoutGrid size={40} className="mx-auto text-muted-foreground/50 mb-4 sm:size-48" />
          <h2 className="text-lg sm:text-xl font-semibold text-muted-foreground">No Layouts Yet</h2>
          <p className="text-sm sm:text-base text-muted-foreground">
            Get started by creating your first control layout.
          </p>
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button asChild size="icon" className="rounded-full mt-4 w-12 h-12">
                  <Link href="/layout-builder/new">
                    <PlusCircle size={24} />
                    <span className="sr-only">Create New Layout</span>
                  </Link>
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Create New Layout</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {layouts.sort((a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()).map((layout) => (
            <LayoutCard
              key={layout.id}
              layout={layout}
              onDelete={handleDeleteLayout}
            />
          ))}
        </div>
      )}
    </div>
  );
}
