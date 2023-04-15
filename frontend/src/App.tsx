// import './App.css';
import './index.css';

// import `ChakraProvider` component
import { ChakraProvider, Container, Tabs } from '@chakra-ui/react'

// @rainbow-me imports
import "@rainbow-me/rainbowkit/styles.css";
import { getDefaultWallets, RainbowKitProvider } from "@rainbow-me/rainbowkit";

import { WagmiConfig, createClient, configureChains } from 'wagmi'
import { polygonZkEvm } from 'wagmi/chains'

import { alchemyProvider } from 'wagmi/providers/alchemy'
import { publicProvider } from 'wagmi/providers/public'

// import { MetaMaskConnector } from 'wagmi/connectors/metaMask'
import { Profile } from './components/Profile';
import { MainTabs } from './components/MainTabs';
import { Heading } from '@chakra-ui/react'

const { chains, provider, webSocketProvider } = configureChains(
  [polygonZkEvm],
  [alchemyProvider({ apiKey: 'yourAlchemyApiKey' }), publicProvider()],
)

const { connectors } = getDefaultWallets({
  appName: "My RainbowKit App",
  chains
});

// Set up client
const wagmiClient = createClient({
  autoConnect: true,
  connectors,
  provider,
  webSocketProvider,
})

function App() {
  return (
    <ChakraProvider>
      <WagmiConfig client={wagmiClient}>
        <RainbowKitProvider chains={chains}>
          <div>
            <header className='navbar'>
              <div>
                <Heading as='h1'>FantaCrypto</Heading>
              </div>
              <Profile />
            </header>
            <Container maxW='xl'>
              <MainTabs />
            </Container>
          </div>
        </RainbowKitProvider>
      </WagmiConfig>
    </ChakraProvider>
  );
}

export default App;
