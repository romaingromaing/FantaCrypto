// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@api3/contracts/v0.8/interfaces/IProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FantaCrypto is Ownable {
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

    mapping (string => address) public proxies;

    constructor() {
        marketCounter = 0;
        proxies["BTC/USD"] = 0xe5Cf15fED24942E656dBF75165aF1851C89F21B5;
        proxies["ETH/USD"] = 0x26690F9f17FdC26D419371315bc17950a0FC90eD;
        proxies["MATIC/USD"] = 0x3ACccB328Db79Af1B81a4801DAf9ac8370b9FBF8;
        proxies["API3/USD"] = 0xf25B7429406B24dA879F0D1a008596b74Fcb9C2F;
    }

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

    function setProxy(string memory name, address _proxy) public onlyOwner {
        proxies[name] = _proxy;
    }

    // function to readDataFeed
    function readDataFeed(string memory proxyName)
        external
        view
        returns (int224 value, uint256 timestamp)
    {
        (value, timestamp) = IProxy(proxies[proxyName]).read();
        
        require(
            value > 0, 
            "Value not positive"
        );
        require(
            timestamp + 1 days > block.timestamp,
            "Timestamp older than one day"
        );
        
        return (value, timestamp);
    }
    
}
