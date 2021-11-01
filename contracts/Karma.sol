// SPDX-License-Identifier: MIT
pragma solidity 0.8;

interface InterfaceKarma {
    function getKarma(address appAddr, address addr) external view returns (uint karma);
    function updateKarma(address addr, int amount) external payable;
}

struct KarmaStruct {
    uint value;  
    uint updateCount;  
}

contract Karma {
    mapping(address => mapping(address => KarmaStruct)) public karmaMap;
    mapping(address => mapping(address => bool)) public optedOut;
    mapping(address => bool) public optedOutAll;
    event karmaUpdated(address app, address user, int amount);

    modifier costs(uint price) {
        require(msg.value >= price);
        _;
    }

    modifier notOptOut(address appAddr, address addr) {
        require(!optedOut[appAddr][addr] && !optedOutAll[addr], "Address has opted out of Karma for this application");
        _;
    }

    function getKarma(address appAddr, address addr) 
    external 
    view 
    notOptOut(appAddr, addr)
    returns (uint karma) {
        karma = karmaMap[appAddr][addr].value;
    }

    function updateKarma(address addr, int amount, uint16 updateFunctionKey) 
    external 
    payable 
    notOptOut(msg.sender, addr)
    {
        KarmaStruct storage karma = karmaMap[msg.sender][addr];
        if (updateFunctionKey == 1) {
            updateByAdd(karma, amount);
        } else if (updateFunctionKey == 2) {
            updateByAvg(karma, amount);
        } else {
            revert("updateFunctionKey is not valid");
        }
        emit karmaUpdated(msg.sender, addr, amount);
    }


    // karma update functions 

    function updateByAdd(KarmaStruct storage karma, int update) 
    internal 
    {
        int weight = 30; 
        int weightDiff = 100 - weight;
        int decayedKarma = int(karma.value) * weightDiff;

        decayedKarma /= 100;
        

        int weightedAmount = update * weight;
        weightedAmount = weightedAmount / 100;
        uint tentativeValue = uint(decayedKarma + weightedAmount);

        if (karma.value + tentativeValue < 0) {
            karma.value = 0;
        } else {
            karma.value = tentativeValue;
        }
        
    }

    function updateByAvg(KarmaStruct storage karma, int update) 
    internal 
    {
        karma.updateCount += 1;
        int diff = update - int(karma.value);
        int tentativeValue = int(karma.value) + (diff / int(karma.updateCount));    
        if (tentativeValue < 0) {
            karma.value = 0;
        } else {
            karma.value = uint(tentativeValue);
        }
    }

    function optOut(address appAddr) 
    external {
    	karmaMap[appAddr][msg.sender].value = 0;
        optedOut[appAddr][msg.sender] = true;
    }

    function optOutAll() 
    external {
        optedOutAll[msg.sender] = true;
    }
}
