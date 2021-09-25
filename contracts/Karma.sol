// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {SafeMath} from '../dependencies/SafeMath.sol';

contract Karma {
  using SafeMath for uint256;

  address admin;
  mapping(address => mapping(address => uint256)) public karmaMap;
  mapping(address => bool) public isAuthorized;

  constructor()  {
    admin = msg.sender;
  }
  function getKarma(address appAddr, address addr) public view returns (uint256 karma) {
      karma = karmaMap[appAddr][addr];
  }
  function raiseKarma(address addr, uint256 amount) public payable {
      require(msg.value > 1);
      require(isAuthorized[msg.sender], "Sender not authorized.");
      karmaMap[msg.sender][addr] = karmaMap[msg.sender][addr].add(amount);
  }
  function lowerKarma(address addr, uint256 amount) public payable {
      require(msg.value > 1);
      require(isAuthorized[msg.sender]);
      karmaMap[msg.sender][addr] = karmaMap[msg.sender][addr].sub(amount);
  }
  function authorize(address addr) public {
      require(msg.sender == admin);
      isAuthorized[addr] = true;   
  }

  function deAuthorize(address addr) public {
      require(msg.sender == admin);
      isAuthorized[addr] = false; 
  }
}
