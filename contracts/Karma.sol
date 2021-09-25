// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Karma {
  address admin;
  mapping(address => mapping(address => uint)) public karmaMap;
  mapping(address => bool) public isAuthorized;
  constructor()  {
    admin = msg.sender;
  }

  //constants
  uint constant SEED = 0;
  uint constant CEILING = type(uint).max;

  function getKarma(address appAddr, address addr) public view returns (uint karma) {
      karma = karmaMap[appAddr][addr];
  }
  function generateKarma(address addr, uint amount) public payable {
      require(msg.value > 1);
      require(isAuthorized[msg.sender], "Sender not authorized.");

      uint karma = karmaMap[msg.sender][addr];

      // TODO  function log2(karma) --------
      // get log2 --> costs <= 600 gas
      uint log2 = 0;
      if (karma >= 2**128) { karma >>= 128; log2 += 128; }
      if (karma >= 2**64) { karma >>= 64; log2 += 64; }
      if (karma >= 2**32) { karma >>= 32; log2 += 32; }
      if (karma >= 2**16) { karma >>= 16; log2 += 16; }
      if (karma >= 2**8) { karma >>= 8; log2 += 8; }
      if (karma >= 2**4) { karma >>= 4; log2 += 4; }
      if (karma >= 2**2) { karma >>= 2; log2 += 2; }
      if (karma >= 2**1) { /* karma >>= 1; */ log2 += 1; }

      // ---

      // += e/log2(k)
      uint increment = amount/log2;  //TODO tryDiv --  https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol#L63
  }
  function destroyKarma(address addr, uint amount) public payable {
      require(msg.value > 1);
      require(isAuthorized[msg.sender]);
      karmaMap[msg.sender][addr] -= amount;
  }
  function authorize(address addr) public {
      require(msg.sender == admin);
      isAuthorized[addr] = true;
  }

  function deAuthorize(address addr) public {
      require(msg.sender == admin);
      isAuthorized[addr] = false;
  }

  function reset(address addr) public {
      // for appAddr in karmaMap
        // karmaMap[appAddr][addr] = SEED
  }

}
