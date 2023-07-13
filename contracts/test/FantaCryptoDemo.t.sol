// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/FantaCryptoDemo.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FantaCryptoDemoTest is Test {
    using Strings for uint256;

    FantaCryptoDemo public fantaCrypto;
    address player1 = address(0);
    address player2 = address(1);
    address player3 = address(2);
    address marketOwner = address(666);
    uint256 forkId;

    function setUp() public {
        forkId = vm.createFork(vm.envString("MAINNET_ZKEVM_RPC_URL"));
        vm.selectFork(forkId);
        vm.makePersistent(address(0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f));
        fantaCrypto = new FantaCryptoDemo();
    }

    function testReadDataFeed() public view {
        // vm.rollFork(bytes32(0x3d59ab6878ce6bf8f821d24c82c1b604eae450447f926f727a17db5efcf2dd75)); // price BTC: $30,694.60
        (int224 btcPrice, uint256 timestamp) = fantaCrypto.readDataFeed("BTC/USD");
        console2.log("BTC/USD price: ", btcPrice/10**18);
        // vm.rollFork(bytes32(0x06b5ac3e24a8005dfd2d6d73c6d07c644c6f2348d3833facc2fb7c7a5d35e43c)); // price BTC: $30,332.0162
        (btcPrice, timestamp) = fantaCrypto.readDataFeed("ETH/USD");
        console2.log("ETH/USD price: ", btcPrice/10**18);
    }

    function testWholeProject() public {
        vm.rollFork(121279); // price BTC: $30,694.60
        uint256 networkFee = 1 gwei;
        vm.fee(networkFee);
        string memory name = "DegensTournament";
        uint256 tokenAmountPerPlayer = 10000 * 10**18;
        uint256 roundDeadline = block.number + 300;
        uint256 marketDeadline = block.number + 600;
        uint256 playerFee = 10**18/100;
        string[] memory blacklistedTokens = new string[](0);
        address[] memory whitelistedPlayers = new address[](0);
        vm.startPrank(marketOwner);
        uint256 marketId = fantaCrypto.createMarket(
            name,
            tokenAmountPerPlayer,
            roundDeadline,
            marketDeadline,
            playerFee,
            blacklistedTokens,
            whitelistedPlayers
        );
        console2.log("Market created. ID: ", marketId.toString());
        vm.stopPrank();
        vm.startPrank(player1);
        uint224 amountUSD = 10000 * 10**18 * 10**17;
        string memory btcPair = "BTC/USD";
        string memory ethPair = "ETH/USD";
        (int224 bitcoinPrice,) = fantaCrypto.readDataFeed(btcPair);
        // convert price to string
        uint224 btcAmount = amountUSD/uint224(bitcoinPrice);
        FantaCryptoDemo.Position memory btcPosition = FantaCryptoDemo.Position(btcPair, btcAmount / 10**18);
        FantaCryptoDemo.Position[] memory positions = new FantaCryptoDemo.Position[](1);
        positions[0] = btcPosition;
        uint256 funds = 10**19;
        vm.deal(player1, funds);
        fantaCrypto.submitPositions{value: playerFee}(marketId, positions);
        console2.log("Player 1 submitted his positions with 0.01 ETH fee");
        assertEq(address(player1).balance, funds - playerFee);
        assertEq(fantaCrypto.marketPools(marketId), playerFee);
        // check that the player has been added to the market and he has submitted his position
        address[] memory players = fantaCrypto.getMarketPlayers(marketId);
        assertEq(players.length, 1);
        FantaCryptoDemo.Position[] memory playerPositions = fantaCrypto.getPlayerPositions(marketId, players[0]);
        assertEq(playerPositions[0].token, btcPosition.token);
        assertEq(playerPositions[0].amount, btcPosition.amount);
        // get frozen token
        FantaCryptoDemo.FrozenToken memory frozenToken = fantaCrypto.getMarketFrozenToken(marketId, btcPair);
        assertTrue(frozenToken.valueStart > 20000 * 10**18);
        assertTrue(frozenToken.valueEnd == 0);
        assertTrue(frozenToken.timestampStart > block.timestamp - 7 days);
        vm.stopPrank();
        vm.startPrank(player2);
        vm.deal(player2, funds);
        (int224 ethPrice,) = fantaCrypto.readDataFeed(ethPair);
        uint224 ethAmount = amountUSD/uint224(ethPrice);
        FantaCryptoDemo.Position memory ethPosition = FantaCryptoDemo.Position(ethPair, ethAmount / 10**18);
        positions[0] = ethPosition;
        fantaCrypto.submitPositions{value: playerFee}(marketId, positions);
        console2.log("Player 2 submitted his positions with 0.01 ETH fee");
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
        vm.rollFork(marketDeadline + 1);
        vm.stopPrank();
        vm.startPrank(marketOwner);
        uint224[] memory tokenValues = new uint224[](5);
        tokenValues[0] = 100000 * 10**18;
        tokenValues[1] = 2200 * 10**18;
        tokenValues[2] = 2 * 10**18;
        tokenValues[3] = 2 * 10**18;
        tokenValues[4] = 7 * 10**18;
        uint256 timestamp = block.timestamp;
        uint256 winnerBalancePre = address(player1).balance;
        console2.log("Winner balance before: ", winnerBalancePre);
        fantaCrypto.closeMarket(marketId, tokenValues, timestamp);
        uint256 winnerBalancePost = address(player1).balance;
        console2.log("Winner balance after: ", winnerBalancePost);
        assertEq(winnerBalancePost, winnerBalancePre + fantaCrypto.marketPools(marketId));
    }
}
