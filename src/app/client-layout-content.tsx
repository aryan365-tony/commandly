
'use client';

import { usePathname } from 'next/navigation';
import { AppHeader } from '@/components/common/header';
import { Toaster } from "@/components/ui/toaster";

export function ClientLayoutContent({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const pathname = usePathname();
  const showHeader = !pathname.startsWith('/controller/');

  return (
    <>
      {showHeader && <AppHeader />}
      <main className="flex-grow container mx-auto px-4 py-8">
        {children}
      </main>
      <Toaster />
      {showHeader && (
        <footer className="py-6 md:px-8 md:py-0 border-t">
          <div className="container flex flex-col items-center justify-center gap-4 md:h-24 md:flex-row">
            <p className="text-balance text-center text-sm leading-loose text-muted-foreground">
              Commandly &copy; {new Date().getFullYear()}
            </p>
          </div>
        </footer>
      )}
    </>
  );
}
