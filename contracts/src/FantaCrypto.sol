// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@api3/contracts/v0.8/interfaces/IProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FantaCrypto is Ownable {
    struct FrozenToken {
        uint224 value;
        uint256 timestamp;
    }

    struct Market {
        string name;
        address admin;
        uint256 tokenAmountPerPlayer;
        uint256 roundDeadline;
        uint256 marketDeadline;
        uint256 playerFee;
        bool publicMarket;
    }

    struct Position {
        string token;
        uint224 amount;
    }

    struct Permissions {
        bool allowed;
        bool inGame;
    }

    mapping(uint256 => Market) public markets;
    mapping(uint256 => address[]) public marketPlayers;
    mapping(uint256 => mapping(address => Permissions)) public marketPlayerPermissions;
    mapping(uint256 => mapping(address => Position[])) public marketPlayerPositions;
    mapping(address => uint256[]) public playerMarkets;
    mapping(uint256 => uint256) public marketPools;
    mapping(uint256 => mapping(string => bool)) marketBlacklistedTokens;
    mapping(uint256 => mapping(string => FrozenToken)) public marketFrozenTokensStart;
    mapping(uint256 => mapping(string => FrozenToken)) public marketFrozenTokensEnd;

    uint256 public marketCounter;

    mapping(string => address) public oracleProxies;
    string[] public oracleProxyNames;

    constructor() {
        marketCounter = 0;
        oracleProxyNames.push("BTC/USD");
        oracleProxies["BTC/USD"] = 0xe5Cf15fED24942E656dBF75165aF1851C89F21B5;
        oracleProxyNames.push("ETH/USD");
        oracleProxies["ETH/USD"] = 0x26690F9f17FdC26D419371315bc17950a0FC90eD;
        oracleProxyNames.push("MATIC/USD");
        oracleProxies["MATIC/USD"] = 0x3ACccB328Db79Af1B81a4801DAf9ac8370b9FBF8;
        oracleProxyNames.push("API3/USD");
        oracleProxies["API3/USD"] = 0xf25B7429406B24dA879F0D1a008596b74Fcb9C2F;
        oracleProxyNames.push("BAL/USD");
        oracleProxies["BAL/USD"] = 0x2434BB8BAFD1552151144b6F56D11fc91621A587;
    }

    function createMarket(
        string memory _name,
        uint256 _tokenAmountPerPlayer,
        uint256 _roundDeadline,
        uint256 _marketDeadline,
        uint256 _playerFee,
        string[] memory _blacklistedTokens,
        address[] memory _whitelistedPlayers
    ) external {
        marketCounter++;
        // empty mapping of blacklisted tokens
        for (uint256 i = 0; i < oracleProxyNames.length; i++) {
            marketBlacklistedTokens[marketCounter][oracleProxyNames[i]] = false;
        }
        // add the blacklisted tokens to the mapping
        for (uint256 i = 0; i < _blacklistedTokens.length; i++) {
            marketBlacklistedTokens[marketCounter][
                _blacklistedTokens[i]
            ] = true;
        }
        Market memory market = Market(
            _name,
            msg.sender,
            _tokenAmountPerPlayer,
            _roundDeadline,
            _marketDeadline,
            _playerFee,
            _whitelistedPlayers.length == 0
        );
        // get the price feed for all the tokens and save them in the frozenTokens, but not if they are blacklisted
        for (uint256 i = 0; i < oracleProxyNames.length; i++) {
            if (!marketBlacklistedTokens[marketCounter][oracleProxyNames[i]]) {
                (int224 value, uint256 timestamp) = this.readDataFeed(
                    oracleProxyNames[i]
                );
                marketFrozenTokensStart[marketCounter][
                    oracleProxyNames[i]
                ] = FrozenToken(uint224(value), timestamp);
            }
        }
        for (uint256 i = 0; i < _whitelistedPlayers.length; i++) {
            marketPlayerPermissions[marketCounter][
                _whitelistedPlayers[i]
            ] = Permissions(true, false);
        }
        markets[marketCounter] = market;
    }

    function submitPositions(
        uint256 _marketId,
        Position[] memory _positions
    ) external payable {
        require(
            msg.value == markets[_marketId].playerFee,
            "You need to pay the player fee"
        );
        require(
            block.timestamp < markets[_marketId].roundDeadline,
            "Round deadline has passed"
        );
        require(
            markets[_marketId].publicMarket ||
                marketPlayerPermissions[_marketId][msg.sender].allowed,
            "You are not whitelisted for this market"
        );
        require(
            !marketPlayerPermissions[_marketId][msg.sender].inGame,
            "You have already submitted your positions"
        );
        uint224 totalValue;
        // calculate the total value of the positions, using the frozen tokens prices
        for (uint256 i = 0; i < _positions.length; i++) {
            require(
                !marketBlacklistedTokens[_marketId][_positions[i].token],
                "You can't use this token"
            );
            totalValue +=
                _positions[i].amount *
                marketFrozenTokensStart[_marketId][_positions[i].token].value;
        }
        require(
            totalValue <= markets[_marketId].tokenAmountPerPlayer,
            "Total value of your positions is higher than the allowed amount"
        );
        marketPlayerPermissions[marketCounter][msg.sender].inGame = true;
        playerMarkets[msg.sender].push(_marketId);
        for (uint256 i = 0; i < _positions.length; i++) {
            marketPlayerPositions[_marketId][msg.sender].push(_positions[i]);
        }
        marketPools[_marketId] += msg.value;
    }

    // TODO: top 3 winners
    function payWinner(uint256 _marketId) external payable {
        require(
            block.timestamp > markets[_marketId].marketDeadline,
            "Market deadline has not passed"
        );
        require(
            markets[_marketId].admin == msg.sender,
            "You are not the admin of this market"
        );
        address winner = getWinner(_marketId);
        payable(winner).transfer(marketPools[_marketId]);
    }

    function getWinner(uint256 _marketId) internal returns (address) {
        // before, we want to get all the current price of the market tokens
        for (uint256 i = 0; i < oracleProxyNames.length; i++) {
            if (!marketBlacklistedTokens[_marketId][oracleProxyNames[i]]) {
                (int224 value, uint256 timestamp) = this.readDataFeed(
                    oracleProxyNames[i]
                );
                marketFrozenTokensEnd[_marketId][
                    oracleProxyNames[i]
                ] = FrozenToken(uint224(value), timestamp);
            }
        }
        address[] memory players = marketPlayers[_marketId];
        Position[][] memory positions = new Position[][](players.length);
        for (uint256 i = 0; i < players.length; i++) {
            positions[i] = marketPlayerPositions[_marketId][players[i]];
        }
        // calculate the total value of each player, and track the highest total value
        uint224[] memory totalValues = new uint224[](players.length);
        uint224 highestTotalValue;
        address winner;
        for (uint256 i = 0; i < players.length; i++) {
            for (uint256 j = 0; j < positions[i].length; j++) {
                totalValues[i] +=
                    positions[i][j].amount *
                    marketFrozenTokensEnd[_marketId][positions[i][j].token]
                        .value;
            }
            if (totalValues[i] > highestTotalValue) {
                highestTotalValue = totalValues[i];
                winner = players[i];
            }
        }
        return winner;
    }

    function setProxy(string memory name, address _proxy) public onlyOwner {
        oracleProxyNames.push(name);
        oracleProxies[name] = _proxy;
    }

    function readDataFeed(
        string memory proxyName
    ) external view returns (int224 value, uint256 timestamp) {
        (value, timestamp) = IProxy(oracleProxies[proxyName]).read();

        require(value > 0, "Value not positive");
        require(
            timestamp + 1 days > block.timestamp,
            "Timestamp older than one day"
        );

        return (value, timestamp);
    }
}
