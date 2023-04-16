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




export function CloseMarketForm() {

    const [marketId, setMarketId] = useState('')
    const [marketIdError, setMarketIdError] = useState('')
    const [tokenPair, setTokenPair] = useState('')
    const [tokenPairError, setTokenPairError] = useState('')
    const [amount, setAmount] = useState('0')
    const [amountError, setAmountError] = useState('')

    const [positionCounter, setPositionCounter] = useState(0)

    return (
        <Formik
            initialValues={{
                market_name: ''
            }}
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
                            <option value='1'>Che_Scoppiati</option>
                            <option value='2'>Casa di Pillon</option>
                        </Select>
                    </FormControl>

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