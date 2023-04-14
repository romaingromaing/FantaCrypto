// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract FantaCrypto {
    struct Market {
        uint256 id;
        string name;
        address admin;
        uint256 tokenPerPlayer;
        uint256 tokenAmountPerPlayer;
        uint256 roundDeadline;
        uint256 marketDeadline;
        uint256 playerFee;
        address[] allowedTokens;
    }

    struct Position {
        address token;
        uint256 amount;
    }

    struct Permissions {
        bool allowed;
        bool inGame;
    }

    mapping(uint256 => Market) public markets;
    mapping(uint256 => mapping(address => Permissions)) public marketPlayers;
    mapping(address => uint256[]) public playerMarkets;
    mapping(uint256 => mapping(address => Position[])) public marketPlayerPositions;
    mapping(uint256 => uint256) public marketPools;

    uint256 public marketCounter;

    function createMarket(
        string memory _name,
        uint256 _tokenPerPlayer,
        uint256 _tokenAmountPerPlayer,
        uint256 _roundDeadline,
        uint256 _marketDeadline,
        uint256 _playerFee,
        address[] memory _allowedTokens,
        address[] memory _whitelistedPlayers
    ) external {
        marketCounter++;
        Market memory market = Market(
            marketCounter,
            _name,
            msg.sender,
            _tokenPerPlayer,
            _tokenAmountPerPlayer,
            _roundDeadline,
            _marketDeadline,
            _playerFee,
            _allowedTokens
        );
        for (uint256 i = 0; i < _whitelistedPlayers.length; i++) {
            marketPlayers[marketCounter][_whitelistedPlayers[i]] = Permissions(true, false);
        }
        markets[marketCounter] = market;
    }

    function submitPositions(
        uint256 _marketId, 
        Position[] memory _positions
    ) 
        external
        payable
    {
        require(
            msg.value == markets[_marketId].playerFee,
            "You need to pay the player fee"
        );
        require(
            block.timestamp < markets[_marketId].roundDeadline,
            "Round deadline has passed"
        );
        require(
            marketPlayers[_marketId][msg.sender].allowed,
            "You are not whitelisted for this market"
        );
        require(
            !marketPlayers[_marketId][msg.sender].inGame,
            "You have already submitted your positions"
        );
        // TODO: check if the total value is <= than allowed (market feed)
        // TODO: check if the number of _positions.length is <= than _tokenPerPlayer
        marketPlayers[marketCounter][msg.sender].inGame = true;
        playerMarkets[msg.sender].push(_marketId);
        for (uint256 i = 0; i < _positions.length; i++) {
            marketPlayerPositions[_marketId][msg.sender].push(_positions[i]);
        }
        marketPools[_marketId] += msg.value;
    }

    // TODO: top 3 winners
    function payWinner(uint256 _marketId) external {
        require(
            block.timestamp > markets[_marketId].marketDeadline,
            "Market deadline has not passed"
        );
        require(
            markets[_marketId].admin == msg.sender,
            "You are not the admin of this market"
        );
        // get all portfolios
        // calculate the total value of each portfolio
        // get the biggest one
        // pay the winner
    }
}
