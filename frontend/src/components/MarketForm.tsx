import {
    FormControl,
    FormLabel,
    FormErrorMessage,
    FormHelperText,
    Input,
    Button,
    NumberInput,
    NumberInputField,
    NumberInputStepper,
    NumberIncrementStepper,
    NumberDecrementStepper,
} from '@chakra-ui/react'

import { ErrorMessage, Field, Form, Formik } from 'formik'
import { useState } from 'react';
import * as Yup from 'yup'

import { Checkbox, CheckboxGroup } from '@chakra-ui/react'

const MarketFormSchema = Yup.object().shape({
    market_name: Yup.string()
        .min(2, 'Too Short!')
        .max(70, 'Too Long!')
        .required('Required'),
    token_amount: Yup.string()
        .min(1, 'Minimum 1!')
        .required('Required'),
});

export function MarketForm() {

    const [marketName, setMarketName] = useState('')
    const [marketNameError, setMarketNameError] = useState('')
    const [tokenAmount, setTokenAmount] = useState('0')
    const [tokenAmountError, setTokenAmountError] = useState('')
    const [roundDeadline, setRoundDeadline] = useState('0')
    const [roundDeadlineError, setRoundDeadlineError] = useState('')
    const [marketDeadline, setMarketDeadline] = useState('0')
    const [marketDeadlineError, setMarketDeadlineError] = useState('')
    const [publicMarket, setPublicMarket] = useState(false)

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
                    <FormControl className="form-control" isInvalid={marketNameError != ""}>
                        <FormLabel>Market Name</FormLabel>
                        <Input type='text' value={marketName} onChange={(e) => {setMarketName(e.target.value)}} />
                        <FormErrorMessage>{marketNameError}</FormErrorMessage>
                    </FormControl>

                    <FormControl className="form-control" isInvalid={tokenAmountError != ""}>
                        <FormLabel>Token Amount</FormLabel>
                        <Input type='number' value={tokenAmount} onChange={(e) => {setTokenAmount(e.target.value)}} />
                        <FormErrorMessage>{tokenAmountError}</FormErrorMessage>
                    </FormControl>

                    <FormControl className="form-control" isInvalid={roundDeadlineError != ""}>
                        <FormLabel>Round Deadline</FormLabel>
                        <Input type='text' value={roundDeadline} onChange={(e) => {setRoundDeadline(e.target.value)}} />
                        <FormErrorMessage>{roundDeadlineError}</FormErrorMessage>
                    </FormControl>

                    <FormControl className="form-control" isInvalid={marketDeadlineError != ""}>
                        <FormLabel>Market Deadline</FormLabel>
                        <Input type='text' value={marketDeadline} onChange={(e) => {setMarketDeadline(e.target.value)}} />
                        <FormErrorMessage>{marketDeadlineError}</FormErrorMessage>
                    </FormControl>

                    <FormControl className="form-control">
                        <Checkbox 
                            defaultChecked
                            onChange={(e) => setPublicMarket(e.target.checked)}
                        >
                            Public
                        </Checkbox>
                    </FormControl>

                    <Button
                        mt={4}
                        colorScheme='blue'
                        // isLoading={props.isSubmitting}
                        type='submit'
                    >
                        Submit
                    </Button>
                </Form>
            )}
        </Formik>
    )
}