// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {SafeMath} from '../dependencies/SafeMath.sol';

interface InterfaceKarma {
    function getKarma(address appAddr, address addr) external view returns (uint karma);
    function raiseKarma(address addr, uint amount) external payable;
    function lowerKarma(address addr, uint amount) external payable;
    function authorize(address addr) external;
    function deAuthorize(address addr) external;
}

contract Karma {
    using SafeMath for uint256;
    address admin;
    mapping(address => mapping(address => uint)) public karmaMap;
    mapping(address => bool) public isAuthorized;
    constructor()  {
        admin = msg.sender;
    }

    modifier onlyAuthorized() {
        require(isAuthorized[msg.sender], "Sender not authorized.");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Sender must be contract admin");
        _;
    } 

    modifier costs(uint price) {
        require(msg.value >= price);
    }

    function getKarma(address appAddr, address addr) external view returns (uint karma) {
        karma = karmaMap[appAddr][addr];
    }
    function raiseKarma(address addr, uint amount) external payable onlyAuthorized costs(1){
        uint256 karma = karmaMap[msg.sender][addr];
        uint weight = 30; // over 100 = 0.3

        uint256 weightDiff = uint(100).sub(weight);
        uint256 decayed_karma = karma.mul(weightDiff);
        decayed_karma = decayed_karma.div(100);
        uint256 weightedAmount = amount.mul(weight);
        uint256 increase = weightedAmount.div(100);
        uint256 new_karma = decayed_karma.add(increase); 

        karmaMap[msg.sender][addr] = new_karma;
    }
    function lowerKarma(address addr, uint amount) external payable onlyAuthorized costs(1){
        uint256 karma = karmaMap[msg.sender][addr];
        uint weight = 40; // over 100 = 0.4

        uint256 weightDiff = uint(100).sub(weight);
        uint256 decayed_karma = karma.mul(weightDiff);
        decayed_karma = decayed_karma.div(100);
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
    function authorize(address addr) external onlyAdmin {
        require(msg.sender == admin);
        isAuthorized[addr] = true;
    }

    function deAuthorize(address addr) external onlyAdmin {
        require(msg.sender == admin);
        isAuthorized[addr] = false;
    }
    function optOut(address addr) external {
    	// allows user to stop being tracked
	//TODO implement
    }
}
