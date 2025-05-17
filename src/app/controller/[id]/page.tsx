
'use client';

import { useEffect, useState, useCallback, useRef } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import type { Layout } from '@/lib/types';
import { getLayoutById } from '@/lib/layouts';
import { useToast } from "@/hooks/use-toast";
import { ArrowLeft, Terminal, WifiOff, Wifi, Settings2, Expand } from 'lucide-react';
import { cn } from '@/lib/utils';

// Dynamically import runtime components
import { RuntimeButton } from '@/components/control-elements/runtime-button';
import { RuntimeSlider } from '@/components/control-elements/runtime-slider';
import { RuntimeJoystick } from '@/components/control-elements/runtime-joystick';
import { RuntimeDPad } from '@/components/control-elements/runtime-dpad';
import { ScrollArea } from '@/components/ui/scroll-area';


export default function ControllerRuntimePage() {
  const params = useParams();
  const router = useRouter();
  const { toast } = useToast();
  
  const layoutId = params.id as string;
  const [layout, setLayout] = useState<Layout | null>(null);
  const [componentStates, setComponentStates] = useState<Record<string, any>>({});
  const [outputArray, setOutputArray] = useState<number[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showDebugLog, setShowDebugLog] = useState(false);
  const sendIntervalRef = useRef<NodeJS.Timeout | null>(null);
  const [isConnected, setIsConnected] = useState(false); 
  // Start in immersive mode by default
  const [isPageFullScreen, setIsPageFullScreen] = useState(true);
  const [debugMessages, setDebugMessages] = useState<string[]>([]);


  const addDebugMessage = useCallback((message: string) => {
    setDebugMessages(prev => [`[${new Date().toLocaleTimeString()}] ${message}`, ...prev.slice(0, 99)]);
  }, []);

  useEffect(() => {
    const loadedLayout = getLayoutById(layoutId);
    if (loadedLayout) {
      setLayout(loadedLayout);
      const initialStates: Record<string, any> = {};
      const maxIndex = loadedLayout.components.reduce((max, c) => Math.max(max, c.outputIndex), -1);
      const initialOutputArray = new Array(maxIndex + 1).fill(0);

      loadedLayout.components.forEach(comp => {
        switch (comp.type) {
          case 'button':
            initialStates[comp.id] = 0; 
            initialOutputArray[comp.outputIndex] = 0;
            break;
          case 'slider':
            const sliderDefault = comp.defaultValue ?? comp.min;
            initialStates[comp.id] = sliderDefault;
            initialOutputArray[comp.outputIndex] = sliderDefault;
            break;
          case 'joystick':
            const center = 128; 
            initialStates[comp.id] = { x: center, y: center };
            if (comp.outputIndex + 1 <= maxIndex) {
              initialOutputArray[comp.outputIndex] = center;
              initialOutputArray[comp.outputIndex + 1] = center;
            } else {
               initialOutputArray[comp.outputIndex] = center;
            }
            break;
          case 'dpad':
            initialStates[comp.id] = { up: 0, down: 0, left: 0, right: 0 };
            initialOutputArray[comp.outputIndex] = 0; 
            break;
        }
      });
      setComponentStates(initialStates);
      setOutputArray(initialOutputArray);
      addDebugMessage(`Layout "${loadedLayout.name}" loaded. ${loadedLayout.components.length} components.`);
      if (loadedLayout.communicationSettings.method) {
        addDebugMessage(`Communication: ${loadedLayout.communicationSettings.method}`);
      } else {
        addDebugMessage(`Communication: Not configured. Click 'Show UI' then 'Connect' to simulate.`);
      }
      

    } else {
      toast({ title: "Error", description: "Layout not found.", variant: "destructive" });
      router.push('/');
    }
    setIsLoading(false);
  }, [layoutId, router, toast, addDebugMessage]);

  const handleComponentStateChange = useCallback((componentId: string, value: any) => {
    setComponentStates(prev => ({ ...prev, [componentId]: value }));
    
    if (layout) {
      const component = layout.components.find(c => c.id === componentId);
      if (component) {
        setOutputArray(prevArray => {
          const newArray = [...prevArray];
          if (component.type === 'joystick') {
            newArray[component.outputIndex] = value.x;
            if (component.outputIndex + 1 < newArray.length) {
              newArray[component.outputIndex + 1] = value.y;
            }
          } else if (component.type === 'dpad') {
            let dpadValue = 0;
            if (value.up) dpadValue |= 1;
            if (value.down) dpadValue |= 2;
            if (value.left) dpadValue |= 4;
            if (value.right) dpadValue |= 8;
            newArray[component.outputIndex] = dpadValue;
          } else {
            newArray[component.outputIndex] = value;
          }
          return newArray;
        });
      }
    }
  }, [layout]);


  useEffect(() => {
    if (!layout || !layout.communicationSettings.method || !isConnected) {
      if (sendIntervalRef.current) clearInterval(sendIntervalRef.current);
      return;
    }

    const sendData = () => {
      addDebugMessage(`Sending data via ${layout.communicationSettings.method}: [${outputArray.join(', ')}]`);
    };

    if (layout.communicationSettings.periodicSending) {
      if (sendIntervalRef.current) clearInterval(sendIntervalRef.current);
      sendIntervalRef.current = setInterval(sendData, layout.communicationSettings.sendInterval);
    } else {
      // If not periodic, send on each change (handled by outputArray dependency)
      sendData(); 
    }
    
    return () => {
      if (sendIntervalRef.current) clearInterval(sendIntervalRef.current);
    };
  }, [outputArray, layout, addDebugMessage, isConnected]); 

  const toggleConnection = () => {
    if (isConnected) {
      setIsConnected(false);
      addDebugMessage("Disconnected.");
       if (sendIntervalRef.current) clearInterval(sendIntervalRef.current);
    } else {
      if (layout && layout.communicationSettings.method) {
        setIsConnected(true);
        addDebugMessage(`Attempting to connect via ${layout.communicationSettings.method}... (Simulated)`);
        // Simulate connection success
        setTimeout(() => {
          addDebugMessage("Connected successfully (Simulated).");
        }, 500);
      } else {
        toast({ title: "Cannot Connect", description: "Communication method not configured for this layout.", variant: "destructive" });
      }
    }
  };

  const togglePageImmersiveMode = async () => {
    const currentDocument = typeof window !== 'undefined' ? window.document : null;
    if (!currentDocument) return;

    if (!isPageFullScreen) { // Entering immersive mode (which implies browser fullscreen)
      try {
        if (!currentDocument.fullscreenElement) {
            await currentDocument.documentElement.requestFullscreen({ navigationUI: "hide" });
        }
        setIsPageFullScreen(true); // Hides UI chrome
      } catch (err) {
        addDebugMessage(`Error attempting to enable full-screen mode: ${err instanceof Error ? err.message : String(err)}`);
        toast({title: "Fullscreen Error", description: "Could not enter fullscreen mode.", variant: "destructive"});
      }
    } else { // Exiting immersive mode
      if (currentDocument.fullscreenElement) {
        await currentDocument.exitFullscreen();
      }
      setIsPageFullScreen(false); // Shows UI chrome
    }
  };

  // Listen to browser's fullscreen changes (e.g. ESC key)
  useEffect(() => {
    const currentDocument = typeof window !== 'undefined' ? window.document : null;
    if (!currentDocument) return () => {};

    const handleFullscreenChange = () => {
      if (!currentDocument.fullscreenElement && isPageFullScreen) {
        setIsPageFullScreen(false); // Exited fullscreen externally
      }
      else if (currentDocument.fullscreenElement && !isPageFullScreen) {
         setIsPageFullScreen(true); // Entered fullscreen externally (less common)
      }
    };
    currentDocument.addEventListener('fullscreenchange', handleFullscreenChange);
    return () => currentDocument.removeEventListener('fullscreenchange', handleFullscreenChange);
  }, [isPageFullScreen]); 

  useEffect(() => {
    if (typeof window !== 'undefined') {
      if (isPageFullScreen) {
        document.body.classList.add('immersive-mode-active');
        document.documentElement.classList.add('immersive-mode-active'); // Apply to html for full coverage
      } else {
        document.body.classList.remove('immersive-mode-active');
        document.documentElement.classList.remove('immersive-mode-active');
      }
    }
    return () => {
      if (typeof window !== 'undefined') {
        document.body.classList.remove('immersive-mode-active');
        document.documentElement.classList.remove('immersive-mode-active');
      }
    };
  }, [isPageFullScreen]);


  if (isLoading || !layout) {
    return <div className="text-center py-10 text-sm sm:text-base">Loading controller...</div>;
  }

  const uiToggleButton = (
    <Button 
      variant="outline" 
      size="icon" 
      onClick={togglePageImmersiveMode} 
      title={isPageFullScreen ? "Show UI & Controls" : "Enter Immersive Mode"} 
      className="fixed top-4 right-4 z-50 rounded-full bg-background/70 hover:bg-background/90"
    >
      {isPageFullScreen ? <Settings2 size={18} /> : <Expand size={18} />}
    </Button>
  );


  return (
    <div className={cn(
        "flex flex-col overscroll-none", 
        isPageFullScreen 
          ? "h-screen w-screen bg-background overflow-hidden fixed inset-0" 
          : "space-y-6 min-h-screen p-4" // Keep original padding if not full screen
    )}>
      {uiToggleButton}

      {!isPageFullScreen && (
        // This header remains, but the main app header from layout.tsx is hidden on this page
        <div className="flex justify-between items-center shrink-0 pt-12 md:pt-0"> {/* Added padding-top for fixed button */}
          <Button variant="outline" size="sm" asChild>
            <Link href="/">
              <ArrowLeft size={16} className="mr-2" /> Back
            </Link>
          </Button>
          <h1 className="text-lg sm:text-xl md:text-2xl font-bold truncate px-2">{layout.name}</h1>
          <div className="flex items-center gap-2">
           <Button variant={isConnected ? "destructive" : "default"} onClick={toggleConnection} size="sm">
              {isConnected ? <WifiOff size={16} className="mr-2" /> : <Wifi size={16} className="mr-2" />}
              {isConnected ? 'Disconnect' : 'Connect'}
            </Button>
            <Button variant="outline" size="icon" onClick={() => setShowDebugLog(!showDebugLog)} title="Toggle Debug Log" className="rounded-full">
              <Terminal size={18} />
            </Button>
          </div>
        </div>
      )}

      <Card className={cn(
        "shadow-lg w-full", 
        isPageFullScreen ? "flex-1 h-full border-none shadow-none overflow-hidden" : "max-w-4xl mx-auto" 
      )}>
        <CardContent 
          className={cn(
            "relative p-0 controller-canvas-bg w-full",
            isPageFullScreen 
              ? "h-full overflow-hidden rounded-none touch-none" // Ensures canvas takes full card height
              : "h-[85vh] overflow-hidden rounded-lg border" 
          )}
          style={isPageFullScreen ? { width: '100%', height: '100%' } : {}} // Explicit full size for canvas
          aria-label="Controller runtime canvas"
        >
          {layout.components.map(comp => {
            const { id, ...restOfComp } = comp;
            const commonProps = {
              // key: id, // key should be applied directly on the component, not in commonProps
              component: comp as any, // Cast to any to satisfy individual component prop types
              onStateChange: handleComponentStateChange,
            };
            switch (comp.type) {
              case 'button': return <RuntimeButton key={id} {...commonProps} />;
              case 'slider': return <RuntimeSlider key={id} {...commonProps} />;
              case 'joystick': return <RuntimeJoystick key={id} {...commonProps} />;
              case 'dpad': return <RuntimeDPad key={id} {...commonProps}/>;
              default: return <div key={id} style={{position: 'absolute', left: `${comp.position.x}px`, top: `${comp.position.y}px`}} className="text-xs">Unknown</div>;
            }
          })}
        </CardContent>
      </Card>

      {!isPageFullScreen && showDebugLog && (
         <Card className={cn("shadow-md shrink-0", !isPageFullScreen && "max-w-4xl mx-auto w-full")}>
          <CardHeader className="py-3 px-4">
            <CardTitle className="text-base md:text-md">Debug Log</CardTitle>
            <CardDescription className="text-xs sm:text-sm">Output: [{outputArray.join(', ')}]</CardDescription>
          </CardHeader>
          <CardContent className={cn("p-0")}>
            <ScrollArea className={cn("w-full rounded-b-md border-t p-3 bg-muted/20", "h-40")}>
              {debugMessages.length === 0 ? (
                <p className="text-xs sm:text-sm text-muted-foreground">No debug messages yet.</p>
              ) : (
                debugMessages.map((msg, index) => (
                  <p key={index} className="text-[10px] sm:text-xs font-mono whitespace-pre-wrap">
                    {msg}
                  </p>
                ))
              )}
            </ScrollArea>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

