// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {SafeMath} from '../dependencies/SafeMath.sol';

contract Karma {
  using SafeMath for uint256;
  address admin;
  mapping(address => mapping(address => uint)) public karmaMap;
  mapping(address => bool) public isAuthorized;
  constructor()  {
    admin = msg.sender;
  }

  function getKarma(address appAddr, address addr) public view returns (uint karma) {
      karma = karmaMap[appAddr][addr];
  }
  function raiseKarma(address addr, uint amount) public payable {
      require(msg.value > 1);
      require(isAuthorized[msg.sender], "Sender not authorized.");

      uint256 karma = karmaMap[msg.sender][addr];
      uint weight = 30; // over 100 = 0.3

      uint256 decayed_karma = karma.mul(uint(100).sub(weight)).div(100);
      uint256 new_karma = decayed_karma.add((amount * weight)/100); // TODO prevent potential overflow

      karmaMap[msg.sender][addr] = new_karma;
  }
  function lowerKarma(address addr, uint amount) public payable {
      require(msg.value > 1);
      require(isAuthorized[msg.sender], "Sender not authorized.");

      uint256 karma = karmaMap[msg.sender][addr];
      uint weight = 40; // over 100 = 0.4

      uint256 decayed_karma = karma.mul(uint(100).sub(weight)).div(100);
      uint256 decrease = amount.mul(weight); //TODO bug here (when going below 0 karma?)
      decrease = decrease.div(100);

      if (decayed_karma >= decrease) {
        uint256 new_karma = decayed_karma.sub(decrease);
        karmaMap[msg.sender][addr] = new_karma;
      }
      else {
        karmaMap[msg.sender][addr] = 0;
      }

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
