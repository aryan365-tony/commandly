
import Link from 'next/link';
import { Gamepad2 } from 'lucide-react';
import { ThemeToggleButton } from './theme-toggle-button';

export function AppHeader() {
  return (
    <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container relative flex h-16 items-center">
        {/* Placeholder for potential left-aligned items, e.g., a mobile menu icon */}
        {/* <div className="absolute left-4 top-1/2 -translate-y-1/2"></div> */}

        <Link href="/" className="flex items-center space-x-2 mx-auto">
          <Gamepad2 className="h-7 w-7 sm:h-8 sm:w-8 text-primary" />
          <span className="text-xl sm:text-2xl font-bold text-foreground">
            Commandly
          </span>
        </Link>
        
        <div className="absolute right-4 top-1/2 -translate-y-1/2">
          <ThemeToggleButton />
        </div>
      </div>
    </header>
  );
}
