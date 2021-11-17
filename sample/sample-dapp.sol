// SPDX-License-Identifier: MIT
pragma solidity 0.8;

interface InterfaceKarma {
    function getKarma(address addr) external view returns (uint karma);
    function updateKarma(address addr, int amount, uint16 updateFunctionKey) external;
}

contract dApp {
    address karmaAddress;
    InterfaceKarma Karma;
    
    function setKarmaAddress(address _karmaAddress) external {
        karmaAddress = _karmaAddress;
        Karma = InterfaceKarma(karmaAddress);
    }
    
    function callGetKarma(address addr) external view returns (uint karma) {
        return Karma.getKarma(addr);
    }
    
    function callUpdateKarma(address addr, int amount) external payable {
        return Karma.updateKarma(addr, amount, 1);
    }   
}