// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/FantaCrypto.sol";

contract FantaCryptoTest is Test {
    FantaCrypto public fantaCrypto;
    address public player1 = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57;

    function setUp() public {
        fantaCrypto = new FantaCrypto();
    }

    function testReadDataFeed() public view {
        string memory market = "BTC/USD";
        (int224 value,) = fantaCrypto.readDataFeed(market);
        console2.log(market, value/10**18);
    }

    function testGiroDelFumo() public {
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
        (int224 bitcoinPrice,) = fantaCrypto.readDataFeed("BTC/USD");
        FantaCrypto.Position memory btcPosition = FantaCrypto.Position("BTC/USD", amountUSD/uint224(bitcoinPrice));
        FantaCrypto.Position[] memory positions = new FantaCrypto.Position[](1);
        positions[0] = btcPosition;
        console2.log("Player funds: ", address(player1).balance);
        // fantaCrypto.submitPositions{value: playerFee}(marketId, positions);
        // vm.stopPrank();
        // // check that the player has been added to the market and he has submitted his position
        // address[] memory players = fantaCrypto.getMarketPlayers(marketId);
        // console2.log("Market Players: ", players[0]);
        // assertEq(players[0], player1);
        // FantaCrypto.Position[] memory playerPositions = fantaCrypto.getPlayerPositions(marketId, player1);
        // console2.log("Player Positions: ", playerPositions[0]);
        // expect(playerPositions[0].market).toEqual(btcPosition);
    }
}
