// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import './Karma.sol';

contract dApp {
    address karmaAddress;
    
    function setKarmaAddress(address _karmaAddress) external {
        karmaAddress = _karmaAddress;
    }
    
    function callGetKarma(address appAddr, address addr) external view returns (uint karma) {
        InterfaceKarma Karma = InterfaceKarma(karmaAddress);
        return Karma.getKarma(appAddr, addr);
    }
    
    function callRaiseKarma(address addr, uint amount) external payable {
        InterfaceKarma Karma = InterfaceKarma(karmaAddress);
        return Karma.raiseKarma{value: msg.value}(addr, amount);
    }
    
    function callLowerKarma(address addr, uint amount) external payable {
        InterfaceKarma Karma = InterfaceKarma(karmaAddress);
        return Karma.lowerKarma{value: msg.value}(addr, amount);
    }
    
    function CallAuthorize(address addr) external {
        InterfaceKarma Karma = InterfaceKarma(karmaAddress);
        Karma.authorize(addr);
    }
    
    function CallDeAuthorize(address addr) external {
        InterfaceKarma Karma = InterfaceKarma(karmaAddress);
        Karma.deAuthorize(addr);
    }
}