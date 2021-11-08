// SPDX-License-Identifier: MIT
pragma solidity 0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Ktoken is ERC20 {
    address karmaAddress;
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000000000 * 10**uint(decimals()));
    }
}