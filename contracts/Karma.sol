// SPDX-License-Identifier: MIT
pragma solidity 0.8;

interface InterfaceKarma {
    function getKarma(address appAddr, address addr) external view returns (uint karma);
    function updateKarma(address addr, int amount, uint16 updateFunctionKey) external payable;
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

    /**
    * @dev Modifier to check if the user has opted out from being tracked with Karma. 
    * @param appAddr The address of the app for which karma is being is being accessed
    * @param addr The address of the user whose karma is being accessed
    **/
    modifier notOptOut(address appAddr, address addr) {
        require(!optedOut[appAddr][addr] && !optedOutAll[addr], "Address has opted out of Karma for this application");
        _;
    }

    /**
    * @dev Function to retireve the karma value for a user. 
    * @param appAddr The address of the app for which karma is being is being accessed
    * @param addr The address of the user whose karma is being accessed
    **/
    function getKarma(address appAddr, address addr) 
    external 
    view 
    notOptOut(appAddr, addr)
    returns (uint karma) {
        karma = karmaMap[appAddr][addr].value;
    }

    /**
    * @dev Function to update a user's karma value for a specified application
    * @param addr The address of the user whose karma is being updated
    * @param amount The amount used to calculate how much should be added or removed from
                    a user's karma value. If the amount is positive, it will increase the 
                    user's karma. If it is negative, it will decrease it. 
    * @param updateFunctionKey An integer specifying which function should be used to update
                               the user's karma. Setting the value to 1 will lead to a weighted 
                               sum updated and setting it to 2 will lead to an averaged sum. 
                               See README for details. 
    **/
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

    /**
    * @dev Function used to update karma through a weighted sum
    * @param karma  The karma object of a user for a given contract address
    * @param update The amount used to calculate how much should be added or removed from
                    a user's karma value. If the amount is positive, it will increase the 
                    user's karma. If it is negative, it will decrease it. 
    **/
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

    /**
    * @dev Function used to update karma through an averaged sum
    * @param karma  The karma object of a user for a given contract address
    * @param update The amount used to calculate how much should be added or removed from
                    a user's karma value. If the amount is positive, it will increase the 
                    user's karma. If it is negative, it will decrease it. 
    **/
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

    /**
    * @dev Function used to opt out of karma tracking for a specified
           application
    * @param appAddr  The address of the application for which the sender
                      wants to opt out. 
    **/
    function optOut(address appAddr) 
    external {
    	karmaMap[appAddr][msg.sender].value = 0;
        optedOut[appAddr][msg.sender] = true;
    }

    /**
    * @dev Function used to opt out of karma tracking for all applications
    **/
    function optOutAll() 
    external {
        optedOutAll[msg.sender] = true;
    }
}
