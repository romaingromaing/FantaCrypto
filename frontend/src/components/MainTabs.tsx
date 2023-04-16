import { Tabs, TabList, TabPanels, Tab, TabPanel } from '@chakra-ui/react'

import { MarketForm } from './MarketForm'

export function MainTabs() {

    return (
        <Tabs variant='soft-rounded' colorScheme='blue' className='tabs'>
            <TabList>
                <Tab color='white'>Create a Market</Tab>
                <Tab color='white'>Put your submission</Tab>
            </TabList>
            <TabPanels>
                <TabPanel>
                    <MarketForm />
                </TabPanel>
                <TabPanel>
                    <p>two!</p>
                </TabPanel>
            </TabPanels>
        </Tabs>
    )
}