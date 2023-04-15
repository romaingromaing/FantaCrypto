// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/FantaCrypto.sol";

contract FantaCryptoTest is Test {
    FantaCrypto public fantaCrypto;
    address player1 = address(0);
    address player2 = address(1);
    address player3 = address(2);

    function setUp() public {
        fantaCrypto = new FantaCrypto();
    }

    function testGiroDelFumo() public {
        // uint256 forkId = vm.createFork(vm.envString("MAINNET_ZKEVM_RPC_URL"));
        // vm.selectFork(forkId);
        // vm.rollFork(125787);
        uint256 networkFee = 1 gwei;
        vm.fee(networkFee);
        string memory name = "CheScoppiatiTournament";
        uint256 tokenAmountPerPlayer = 100;
        uint256 roundDeadline = block.timestamp + 100;
        uint256 marketDeadline = block.timestamp + 200;
        uint256 playerFee = 10**18/100;
        string[] memory blacklistedTokens = new string[](0);
        address[] memory whitelistedPlayers = new address[](0);
        uint256 marketId = fantaCrypto.createMarket(
            name,
            tokenAmountPerPlayer,
            roundDeadline,
            marketDeadline,
            playerFee,
            blacklistedTokens,
            whitelistedPlayers
        );
        console2.log("Market ID: ", marketId);
        vm.startPrank(player1);
        uint224 amountUSD = 100;
        string memory btcPair = "BTC/USD";
        string memory ethPair = "ETH/USD";
        (int224 bitcoinPrice,) = fantaCrypto.readDataFeed(btcPair);
        // convert price to string
        console2.log("BTC/USD price: ", bitcoinPrice);
        FantaCrypto.Position memory btcPosition = FantaCrypto.Position(btcPair, amountUSD/uint224(bitcoinPrice));
        FantaCrypto.Position[] memory positions = new FantaCrypto.Position[](1);
        positions[0] = btcPosition;
        uint256 funds = 10**19;
        vm.deal(player1, funds);
        fantaCrypto.submitPositions{value: playerFee}(marketId, positions);
        assertEq(address(player1).balance, funds - playerFee);
        assertEq(fantaCrypto.marketPools(marketId), playerFee);
        // check that the player has been added to the market and he has submitted his position
        address[] memory players = fantaCrypto.getMarketPlayers(marketId);
        assertEq(players.length, 1);
        FantaCrypto.Position[] memory playerPositions = fantaCrypto.getPlayerPositions(marketId, players[0]);
        assertEq(playerPositions[0].token, btcPosition.token);
        assertEq(playerPositions[0].amount, btcPosition.amount);
        // get frozen token
        FantaCrypto.FrozenToken memory frozenToken = fantaCrypto.getMarketFrozenToken(marketId, btcPair);
        assertTrue(frozenToken.valueStart > 20000 * 10**18);
        assertTrue(frozenToken.valueEnd == 0);
        assertTrue(frozenToken.timestampStart > block.timestamp - 7 days);
        vm.stopPrank();
        vm.startPrank(player2);
        vm.deal(player2, funds);
        (int224 ethPrice,) = fantaCrypto.readDataFeed(ethPair);
        console2.log("ETH/USD price: ", ethPrice);
        FantaCrypto.Position memory ethPosition = FantaCrypto.Position(ethPair, amountUSD/uint224(ethPrice));
        positions[0] = ethPosition;
        fantaCrypto.submitPositions{value: playerFee}(marketId, positions);
        assertEq(address(player2).balance, funds - playerFee);
        assertEq(fantaCrypto.marketPools(marketId), playerFee * 2);
        // check that the player has been added to the market and he has submitted his position
        players = fantaCrypto.getMarketPlayers(marketId);
        assertEq(players.length, 2);
        playerPositions = fantaCrypto.getPlayerPositions(marketId, players[1]);
        assertEq(playerPositions[0].token, ethPosition.token);
        assertEq(playerPositions[0].amount, ethPosition.amount);
        // get frozen token
        frozenToken = fantaCrypto.getMarketFrozenToken(marketId, ethPair);
        assertTrue(frozenToken.valueStart > 1800 * 10**18);
        assertTrue(frozenToken.valueEnd == 0);
        assertTrue(frozenToken.timestampStart > block.timestamp - 7 days);
        vm.rollFork(125787);
        (bitcoinPrice,) = fantaCrypto.readDataFeed(btcPair);
        console2.log("BTC/USD price: ", bitcoinPrice);
        (ethPrice,) = fantaCrypto.readDataFeed(ethPair);
        console2.log("ETH/USD price: ", ethPrice);
    }
}
