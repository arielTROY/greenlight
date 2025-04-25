import React, {
  createContext,
  useContext,
  useEffect,
  useRef,
  useState,
  ReactNode,
} from 'react';

import { createTRPCReact } from '@trpc/react-query';
import { QueryClient } from '@tanstack/react-query';
import { createWSClient, wsLink } from '@trpc/client';
import AppRouter from '@greenlight/platform/src/trpc'

export const trpcReact = createTRPCReact<typeof AppRouter>();

export const TrpcProvider = ({ children }: { children: ReactNode }) => {
    const [queryClient] = useState(() => new QueryClient());
    const [trpcClient, setTrpcClient] = useState(() =>
        trpcReact.createClient({
            links: [
                wsLink({
                    client: createWSClient({
                        url: createWebsocketUrl(),
                    }),
                })
            ]
        })
    );

    function createWebsocketUrl() {
        let wsPort = 5050
        let wsHost = 'localhost'
        let wsProtocol = 'ws'
    
        if (typeof window !== "undefined") {
          wsPort = Number(localStorage.getItem('ws_port')) || 5050
          wsHost = localStorage.getItem('ws_host') || 'localhost'
          wsProtocol = localStorage.getItem('ws_protocol') || 'ws'
        }
        return `${wsProtocol}://${wsHost}:${wsPort}`;
    }

  return (
    <trpcReact.Provider client={trpcClient} queryClient={queryClient}>
      {children}
    </trpcReact.Provider>
  );
};
