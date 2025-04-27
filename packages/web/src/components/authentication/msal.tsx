import Head from 'next/head'
import { setLocalStorage } from '../../utils/localstorage'
import { useTRPC } from '../../utils/trpc';
import { useQuery } from '@tanstack/react-query';

export default function MsalAuthentication() {
  const trpc = useTRPC()

  const msalBootstrap = useQuery(trpc.auth_msal_start.queryOptions())
  const msalLoginCallback = useQuery({
    ...trpc.auth_msal_verify.queryOptions(msalBootstrap.data?.device_code as string),
    enabled: !!msalBootstrap.data?.device_code,
  })

  if(msalLoginCallback.data !== undefined) {
    setLocalStorage('auth_data_msal', JSON.stringify(msalLoginCallback.data));
    setLocalStorage('auth_method', 'msal');

    // Reload page
    window.location.reload();
  }

  return (
    <>
      <Head>
        <title>Authentication</title>
      </Head>
        { msalBootstrap.isLoading ? 'Loading authentication url...' : msalBootstrap.data?.message }
    </>
  );
}
