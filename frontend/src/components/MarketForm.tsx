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
import { prepareWriteContract, writeContract } from '@wagmi/core'
import { polygonZkEvm } from '@wagmi/chains';



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
    const [playerFee, setPlayerFee] = useState('0')
    const [playerFeeError, setPlayerFeeError] = useState('')
    const [publicMarket, setPublicMarket] = useState(false)
    
    async function wagmiCall() {

        // commentata perchè va in errore la questione ABI

        // const config = await prepareWriteContract({
        //     address: '0xecb504d39723b0be0e3a9aa33d646642d1051ee1',
        //     abi: {},
        //     functionName: 'createMarket',
        //     args: [
        //         marketName,
        //         tokenAmount,
        //         roundDeadline,
        //         marketDeadline,
        //         playerFee,
        //         [],
        //         ['0x5e3F50a4171fa7bfE05D5347CC544833c83b3Ee9'],
        //         publicMarket
        //     ],
        //     chainId: polygonZkEvm.id
        // })
        
        // const data = await writeContract(config)

        return true
    }
    

    return (
        <Formik
            initialValues={{
                market_name: ''
            }}
            // validationSchema={MarketFormSchema}  // this works but I didn't set the error messages :)
            onSubmit={(values, actions) => {
                wagmiCall()
                .then(() => {
                    console.log('success')
                })
                .catch((err) => {
                    console.log(err)
                })
            }}
        >
            {(props) => (
                <Form className='forms'>
                    <FormControl className="form-control" isInvalid={marketNameError != ""}>
                        <FormLabel>Market Name</FormLabel>
                        <Input type='text' value={marketName} onChange={(e) => { setMarketName(e.target.value) }} />
                        <FormErrorMessage>{marketNameError}</FormErrorMessage>
                    </FormControl>

                    <FormControl className="form-control" isInvalid={tokenAmountError != ""}>
                        <FormLabel>Token Amount</FormLabel>
                        <Input type='number' value={tokenAmount} onChange={(e) => { setTokenAmount(e.target.value) }} />
                        <FormErrorMessage>{tokenAmountError}</FormErrorMessage>
                    </FormControl>

                    <FormControl className="form-control" isInvalid={roundDeadlineError != ""}>
                        <FormLabel>Round Deadline</FormLabel>
                        <Input type='text' value={roundDeadline} onChange={(e) => { setRoundDeadline(e.target.value) }} />
                        <FormErrorMessage>{roundDeadlineError}</FormErrorMessage>
                    </FormControl>

                    <FormControl className="form-control" isInvalid={marketDeadlineError != ""}>
                        <FormLabel>Market Deadline</FormLabel>
                        <Input type='text' value={marketDeadline} onChange={(e) => { setMarketDeadline(e.target.value) }} />
                        <FormErrorMessage>{marketDeadlineError}</FormErrorMessage>
                    </FormControl>

                    <FormControl className="form-control" isInvalid={playerFeeError != ""}>
                        <FormLabel>Player Fee</FormLabel>
                        <Input type='number' value={playerFee} onChange={(e) => { setPlayerFee(e.target.value) }} />
                        <FormErrorMessage>{playerFee}</FormErrorMessage>
                    </FormControl>

                    <FormControl className="form-control">
                        <Checkbox
                            isChecked={publicMarket}
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