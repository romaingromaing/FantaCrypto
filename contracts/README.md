# FantaCrypto contracts

To run the test forking the Polygon zkEVM mainnet, run:
```bash
forge test --via-ir
```

To deploy on a local node forking the Polygon zkEVM mainnet, run:
```bash
cp .env.example .env # and fill in the missing values
source .env
anvil -f $MAINNET_ZKEVM_RPC_URL --fork-block-number 121279
forge script script/Deploy.s.sol:Deploy --fork-url $LOCAL_URL --broadcast --via-ir --legacy -vvvv
```