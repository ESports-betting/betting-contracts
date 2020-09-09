// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract MoneyMatchToken is ERC20 {
    constructor(uint256 initialSupply) public ERC20("Money Match", "MATCH") {
        _mint(msg.sender, initialSupply);
    }
}