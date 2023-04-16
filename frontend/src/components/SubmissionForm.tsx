import {
    FormControl,
    FormLabel,
    FormErrorMessage,
    Input,
    Button,
    Select,
    Heading,
    Divider,
    HStack,
    Card, CardHeader, CardBody, CardFooter, Stack, StackDivider, Box, VStack
} from '@chakra-ui/react'

import { Form, Formik } from 'formik'
import { useState } from 'react';
import * as Yup from 'yup'

import { readContract, prepareWriteContract, writeContract } from '@wagmi/core'
import { polygonZkEvm } from '@wagmi/chains';
import { useAccount } from 'wagmi';

const MarketFormSchema = Yup.object().shape({
    market_name: Yup.string()
        .min(2, 'Too Short!')
        .max(70, 'Too Long!')
        .required('Required'),
    token_amount: Yup.string()
        .min(1, 'Minimum 1!')
        .required('Required'),
});

let tokenPairs: string[] = []
let amounts: string[] = []

export function SubmissionForm() {

    const [marketId, setMarketId] = useState('')
    const [marketIdError, setMarketIdError] = useState('')
    const [tokenPair, setTokenPair] = useState('')
    const [tokenPairError, setTokenPairError] = useState('')
    const [amount, setAmount] = useState('0')
    const [amountError, setAmountError] = useState('')

    const [positionCounter, setPositionCounter] = useState(0)

    const { address } = useAccount()

    function readAvailableMarkets() {

        // commentata perchè va in errore la questione ABI

        // const data = readContract({
        //     address: '0xecb504d39723b0be0e3a9aa33d646642d1051ee1',
        //     abi: wagmigotchiABI,
        //     functionName: 'getPlayerMarkets',
        //     chainId: polygonZkEvm.id,
        //     args: [address]
        // })

        // data.then(() => {
        //     return ["Che_Scoppiati", "Casa di Pillon"]
        // })
        
        console.log(address)
        return ["Che_Scoppiati", "Casa di Pillon"]
    }

    type Position = {
        tokenPair: string,
        amount: string
    }

    function submitPositions() {
        // create positions array with tokenPair and amount
        let positions = []
        for (let i = 0; i < tokenPairs.length; i++) {
            positions.push({
                tokenPair: tokenPairs[i],
                amount: amounts[i]
            } as Position)
        }

        // commentata perchè va in errore la questione ABI

        // const config = await prepareWriteContract({
        //     address: '0xecb504d39723b0be0e3a9aa33d646642d1051ee1',
        //     abi: {},
        //     functionName: 'submitPositions',
        //     args: [
        //         marketId,
        //         positions
        //     ],
        //     chainId: polygonZkEvm.id
        // })
        
        // const data = await writeContract(config)
    }


    return (
        <Formik
            initialValues={{
                market_name: ''
            }}
            validationSchema={MarketFormSchema}
            onSubmit={(values, actions) => {
                setTimeout(() => {
                    alert(JSON.stringify(values, null, 2))
                    actions.setSubmitting(false)
                }, 1000)
            }}
        >
            {(props) => (
                <Form className='forms'>
                    <FormControl className="form-control" isInvalid={marketIdError != ""}>
                        <FormLabel>Market</FormLabel>
                        <Select placeholder='Select a Market' bg='white' color='black'>
                            {readAvailableMarkets().map((market, index) => (
                                <option value={index}>{market}</option>
                            ))}
                        </Select>
                    </FormControl>


                    <Heading as="h3" mt="5">Your submissions</Heading>
                    <FormControl className="form-control" isInvalid={tokenPairError != ""}>
                        <HStack justifyContent="space-evenly">
                            <div>
                                <FormLabel>Token Pair</FormLabel>
                                <Select
                                    placeholder='Select a Token'
                                    bg='white'
                                    color='black'
                                    value={tokenPair}
                                    onChange={(e) => { setTokenPair(e.target.value) }}
                                >
                                    <option value='BTC/USD'>BTC/USD</option>
                                    <option value='ETH/USD'>ETH/USD</option>
                                </Select>
                            </div>
                            <div>
                                <FormLabel>Amount</FormLabel>
                                <Input type='number' value={amount} onChange={(e) => { setAmount(e.target.value) }} />
                                <FormErrorMessage>{0}</FormErrorMessage>
                            </div>
                        </HStack>
                    </FormControl>

                    <FormControl display="flex" justifyContent="space-around">
                        <Button
                            colorScheme='orange'
                            mt={5}
                            onClick={() => {
                                tokenPairs.push(tokenPair)
                                amounts.push(amount)

                                setTokenPair('')
                                setAmount('0')
                                setPositionCounter(positionCounter + 1)
                            }}
                        >
                            Confirm position
                        </Button>
                    </FormControl>

                    <HStack mt={6}>
                        {
                            tokenPairs.map((tokenPair, index) => (
                                <Card>
                                    <CardHeader>
                                        <Heading size='md'>{tokenPair}</Heading>
                                    </CardHeader>

                                    <CardBody>
                                        <Stack divider={<StackDivider />} spacing='4'>
                                            <Box>
                                                <Heading size='xs' textTransform='uppercase'>
                                                    Amount
                                                </Heading>
                                                {amounts[index]}
                                            </Box>
                                        </Stack>
                                    </CardBody>
                                </Card>
                            ))
                        }

                    </HStack>

                    <Divider mt="5" />

                    <VStack alignItems="flex-start" mt={6}>
                        <p>Remember to confirm your submission!</p>
                        <Button
                            mt={4}
                            colorScheme='blue'
                            // isLoading={props.isSubmitting}
                            type='submit'
                        >
                            Submit
                        </Button>
                    </VStack>
                </Form>
            )}
        </Formik>
    )
}