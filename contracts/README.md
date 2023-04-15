# FantaCrypto contracts

To test forking the Polygon zkEVM mainnet, run:
```bash
forge test --fork-url $MAINNET_ZKEVM_RPC_URL
```

To deploy contracts on the Polygon zkEVM testnet, run:
```bash
forge script script/Deploy.s.sol:Deploy --rpc-url $POLYGON_ZKEVM_RPC_URL --broadcast -vvvv --legacy
```