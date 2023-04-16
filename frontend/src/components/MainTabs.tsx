import { Tabs, TabList, TabPanels, Tab, TabPanel, Heading, Text } from '@chakra-ui/react'

import { MarketForm } from './MarketForm'
import { SubmissionForm } from './SubmissionForm'
import { CloseMarketForm } from './CloseMarketForm'

export function MainTabs() {

    return (
        <Tabs variant='soft-rounded' colorScheme='blue' className='tabs'>
            <TabList>
                <Tab color='white'>Create a Market</Tab>
                <Tab color='white'>Put your submission</Tab>
                <Tab color='white'>Close a Market</Tab>
            </TabList>
            <TabPanels>
                <TabPanel>
                    <Heading as='h2'>Create a new FantaCrypto Market</Heading>
                    <Text mt="3">First of all create your Market! Here you can customise all its details and you will ready to compete with other people.</Text>
                    <MarketForm />
                </TabPanel>
                <TabPanel>
                    <Heading as='h2'>Create your submission for a Market</Heading>
                    <Text mt="3">Then, choose your team!</Text>
                    <SubmissionForm />
                </TabPanel>
                <TabPanel>
                    <Heading as='h2'>Close a Market</Heading>
                    <Text mt="3">Like other cool stuff, this one is finished too. It's time to get a winner!</Text>
                    <CloseMarketForm />
                </TabPanel>
            </TabPanels>
        </Tabs>
    )
}