// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralisedExchange {
    address public owner;
    mapping(address => mapping(address => uint256)) public liquidity;
    mapping(address => mapping(address => uint256)) public tokenReserves;

    event LiquidityAdded(address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB);
    event TokenSwapped(address indexed fromToken, address indexed toToken, uint256 amountIn, uint256 amountOut);

    constructor() {
        owner = msg.sender;
    }

    function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external {
        liquidity[tokenA][tokenB] += amountA;
        liquidity[tokenB][tokenA] += amountB;

        tokenReserves[tokenA][tokenB] += amountA;
        tokenReserves[tokenB][tokenA] += amountB;

        emit LiquidityAdded(tokenA, tokenB, amountA, amountB);
    }

    function getSwapRate(address fromToken, address toToken, uint256 amountIn) public view returns (uint256) {
        require(tokenReserves[fromToken][toToken] > 0, "Insufficient liquidity");

        // Simple 1:1 ratio for demo; real DEXs use constant product formula (x*y=k)
        uint256 rate = tokenReserves[toToken][fromToken] / tokenReserves[fromToken][toToken];
        return amountIn * rate;
    }

    function swap(address fromToken, address toToken, uint256 amountIn) external {
        uint256 amountOut = getSwapRate(fromToken, toToken, amountIn);
        require(tokenReserves[toToken][fromToken] >= amountOut, "Not enough liquidity");

        tokenReserves[fromToken][toToken] += amountIn;
        tokenReserves[toToken][fromToken] -= amountOut;

        emit TokenSwapped(fromToken, toToken, amountIn, amountOut);
    }
}
