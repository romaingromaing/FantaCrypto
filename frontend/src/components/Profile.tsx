import {
    useAccount,
    useConnect,
    useEnsAvatar,
    useEnsName,
} from 'wagmi'

import { ConnectButton } from "@rainbow-me/rainbowkit";


export function Profile() {
    const { address } = useAccount()

    console.log(address)

    return (
        <div
            style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "center"
            }}
        >
            <ConnectButton />
        </div>
    )
}
