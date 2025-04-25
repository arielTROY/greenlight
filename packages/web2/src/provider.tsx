// import type { NavigateOptions } from "react-router-dom";

import { HeroUIProvider } from "@heroui/system";
import { useHref, useNavigate } from "react-router-dom";

import { GamepadNavigationProvider } from './providers/gamepadnav'
import { TrpcProvider } from './providers/trpc'

// declare module "@react-types/shared" {
//   interface RouterConfig {
//     routerOptions: NavigateOptions;
//   }
// }

export function Provider({ children }: { children: React.ReactNode }) {
  const navigate = useNavigate();

  return (
    <TrpcProvider>
      <GamepadNavigationProvider>
        <HeroUIProvider navigate={navigate} useHref={useHref}>
          {children}
        </HeroUIProvider>
      </GamepadNavigationProvider>
    </TrpcProvider>
  );
}
