
'use client';

import type { Layout } from '@/lib/types';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Edit3, Play, Trash2, ArrowUpRightSquare, Clock } from 'lucide-react';
import Link from 'next/link';
import { formatDistanceToNow } from 'date-fns';
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";

interface LayoutCardProps {
  layout: Layout;
  onDelete: (id: string) => void;
}

export function LayoutCard({ layout, onDelete }: LayoutCardProps) {
  const handleDelete = () => {
    if (window.confirm(`Are you sure you want to delete "${layout.name}"?`)) {
      onDelete(layout.id);
    }
  };

  const handleOpenFullscreen = () => {
    const controllerUrl = `/controller/${layout.id}`;
    window.open(controllerUrl, '_blank', 'noopener,noreferrer');
  };

  const lastUpdated = formatDistanceToNow(new Date(layout.updatedAt), { addSuffix: true });

  return (
    <TooltipProvider>
      <Card className="flex flex-col shadow-lg hover:shadow-xl transition-shadow duration-300">
        <CardHeader>
          <CardTitle className="text-lg md:text-xl">{layout.name}</CardTitle>
          <CardDescription className="flex items-center text-xs text-muted-foreground">
            <Clock size={14} className="mr-1" /> Last updated: {lastUpdated}
          </CardDescription>
        </CardHeader>
        <CardContent className="flex-grow">
          <p className="text-xs sm:text-sm text-muted-foreground">
            Components: {layout.components.length}
          </p>
          <p className="text-xs sm:text-sm text-muted-foreground mt-1">
            Comm method: {layout.communicationSettings.method ? layout.communicationSettings.method.replace(/_/g, ' ') : 'Not set'}
          </p>
        </CardContent>
        <CardFooter className="flex justify-between items-center pt-4">
          <div className="flex gap-2">
            <Tooltip>
              <TooltipTrigger asChild>
                <Button variant="outline" size="icon" className="rounded-full" asChild>
                  <Link href={`/layout-builder/${layout.id}`}>
                    <Edit3 size={18} />
                    <span className="sr-only">Edit Layout</span>
                  </Link>
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Edit Layout</p>
              </TooltipContent>
            </Tooltip>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button variant="destructive" size="icon" className="rounded-full" onClick={handleDelete}>
                  <Trash2 size={18} />
                  <span className="sr-only">Delete Layout</span>
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Delete Layout</p>
              </TooltipContent>
            </Tooltip>
          </div>
          <div className="flex gap-2">
            <Tooltip>
              <TooltipTrigger asChild>
                <Button variant="outline" size="icon" className="rounded-full" onClick={handleOpenFullscreen}>
                  <ArrowUpRightSquare size={18} />
                  <span className="sr-only">Open in new window</span>
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Open in new window</p>
              </TooltipContent>
            </Tooltip>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button size="icon" className="rounded-full bg-primary hover:bg-primary/90" asChild>
                  <Link href={`/controller/${layout.id}`}>
                    <Play size={18} />
                    <span className="sr-only">Open Controller</span>
                  </Link>
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Open Controller</p>
              </TooltipContent>
            </Tooltip>
          </div>
        </CardFooter>
      </Card>
    </TooltipProvider>
  );
}
