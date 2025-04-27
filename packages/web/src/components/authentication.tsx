import { useState, Fragment } from 'react'
import { Button, CircularProgress, Card, CardBody } from '@heroui/react'

import Head from 'next/head'

import { getLocalStorage, getSessionStorage, setSessionStorage, removeSessionStorage } from '../utils/localstorage'
import { useTRPC } from '../utils/trpc';
import { getWebToken } from '../utils/tokenhelper';
import { useQuery } from '@tanstack/react-query';

import MsalAuthentication from './authentication/msal'

/*
 The authentication component is responsible for handling the authentication flow for the application. It checks if the user is signed in,
 and if not, it displays the available authentication methods (XAL and MSAL).
 If the user is signed in, it retrieves the necessary tokens and displays the main application content.

 Tokens are shared via a session storage, and the authentication method is stored in local storage.
 The component uses the `trpcReact` library to fetch the tokens from the server.
*/

interface AuthenticationProps {
  children: React.ReactNode;
}

export default function Authentication({ children }:AuthenticationProps) {
  const trpc = useTRPC()



  const [authMethod, setAuthMethod] = useState('none')
  const [signedInMethod] = useState(getLocalStorage('auth_method') ?? 'none')
  const [userToken] = useState(getLocalStorage('auth_data_msal') ?? '{}')

  // Check if we have local tokens
  const [webToken] = useState(getSessionStorage('auth_web_token') ?? undefined)
  const [xCloudToken] = useState(getSessionStorage('auth_xcloud_token') ?? undefined)
  const [xHomeToken] = useState(getSessionStorage('auth_xhome_token') ?? undefined)
  
  const authStreamingTokens = useQuery({
    ...trpc.auth_get_streamingtokens.queryOptions(userToken as string),
    enabled: (signedInMethod !== 'none' && (xCloudToken === undefined || xHomeToken === undefined )),
  })

  const authWebTokens = useQuery({
    ...trpc.auth_get_webtoken.queryOptions(userToken as string),
    enabled: (signedInMethod !== 'none' && webToken === undefined),
  })

  // Workaround for server-side rendering issues
  // const [isMounted, setIsMounted] = useState(false);
  // useEffect(() => {
  //   setIsMounted(true);
  // }, []);

  // if (!isMounted) {
  //   // Render nothing on the server to avoid mismatched HTML
  //   return null;
  // }

  if(authWebTokens.isSuccess && authWebTokens.data !== undefined){
    setSessionStorage('auth_web_token', JSON.stringify(authWebTokens.data.data))
    const date = new Date(authWebTokens.data.data.NotAfter)
    setSessionStorage('auth_web_token_expires', date.toISOString())
  }
  if(authStreamingTokens.isSuccess && authStreamingTokens.data !== undefined){
    setSessionStorage('auth_xcloud_token', JSON.stringify(authStreamingTokens.data.xCloudToken.data))
    setSessionStorage('auth_xhome_token', JSON.stringify(authStreamingTokens.data.xHomeToken.data))
  }

  // Test if we can load the tokens if they are set.
  if(webToken !== undefined && xCloudToken !== undefined && xHomeToken !== undefined) {
    // Check for web token
    const token = getWebToken()
    if(token.token === undefined || token.uhs === undefined) {
      // We dont have a valid token, so we need to sign in again
      removeSessionStorage('auth_web_token')
      removeSessionStorage('auth_xcloud_token')
      removeSessionStorage('auth_xhome_token')
    }

    // Check the streaming tokens
    // @TODO: todo to implement
  }

  return (
    <>
      <Head>
        <title>Authentication</title>
      </Head>
      {
        signedInMethod !== 'none' ? 
          // We are signed in, but we dont have tokens yet..
          (authStreamingTokens.isLoading || authWebTokens.isLoading) ?
            <main className="container mx-auto max-w-screen px-6 flex-grow pt-16">
              <Card><CardBody>
                <center>
                  <CircularProgress label="Authenticating..." />
                  <br />
                  {(authWebTokens.isLoading === true) ? <p className="text-center">Retrieving web token...</p> : ''}
                  {(authStreamingTokens.isLoading === true) ? <p className="text-center">Retrieving streaming tokens...</p> : ''}
                </center>
              </CardBody></Card>
            </main> :
          // We are signed in, and we have the session tokens in the sessionStorage so lets show the UI
            <div>{ children }</div> :
        // We are not signed in, so we need to show the authentication methods & subpages
        <main className="container mx-auto max-w-screen px-6 flex-grow pt-16">
          { authMethod === "msal" ? 
            <MsalAuthentication /> :
            <Fragment>
              <center>
                <Button tabIndex={0} key='1'data-nav data-nav-group="default" color="primary" onPress={() => { setAuthMethod('xal') }}>Start XAL</Button>
                <Button tabIndex={0} key='2' data-nav data-nav-group="default" color="primary" onPress={() => { setAuthMethod('msal') }}>Start MSAL</Button>
              </center>
            </Fragment>
          }
        </main>
      }
    </>
  );
}
