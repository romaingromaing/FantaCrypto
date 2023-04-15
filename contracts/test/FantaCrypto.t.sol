// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/FantaCrypto.sol";

contract FantaCryptoTest is Test {
    FantaCrypto public fantaCrypto;

    function setUp() public {
        fantaCrypto = new FantaCrypto();
    }

    function testReadDataFeed() public view {
        (int224 value, uint256 timestamp) = fantaCrypto.readDataFeed("API3/USD");
        console2.log("API3/USD value: ", value);
    }
}
