import { Tabs, TabList, TabPanels, Tab, TabPanel } from '@chakra-ui/react'


export function MainTabs() {

    return (
        <Tabs isFitted variant='enclosed'>
            <TabList mb='1em'>
                <Tab>One</Tab>
                <Tab>Two</Tab>
            </TabList>
            <TabPanels>
                <TabPanel>
                    <p>one!</p>
                </TabPanel>
                <TabPanel>
                    <p>two!</p>
                </TabPanel>
            </TabPanels>
        </Tabs>
    )
}