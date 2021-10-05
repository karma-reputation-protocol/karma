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

    function callGenerateKarma(address addr, uint amount) external payable {
        InterfaceKarma Karma = InterfaceKarma(karmaAddress);
        return Karma.generateKarma{value: msg.value}(addr, amount);
    }

    function callDestroyKarma(address addr, uint amount) external payable {
        InterfaceKarma Karma = InterfaceKarma(karmaAddress);
        return Karma.destroyKarma{value: msg.value}(addr, amount);
    }

    function callAuthorize(address addr) external {
        InterfaceKarma Karma = InterfaceKarma(karmaAddress);
        Karma.authorize(addr);
    }

    function callDeAuthorize(address addr) external {
        InterfaceKarma Karma = InterfaceKarma(karmaAddress);
        Karma.deAuthorize(addr);
    }
}
