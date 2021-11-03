// SPDX-License-Identifier: MIT
pragma solidity 0.8;

interface InterfaceKarmaStore {
    function readKarma(address appAddr, address addr) external view returns (KarmaStruct memory karma);
    function writeKarma(address appAddr, address addr, uint value, uint[] calldata metadata) external;
}

struct KarmaStruct {
    uint value;  
    uint[] metadata;  
}

contract Karma {

    address admin;
    InterfaceKarmaStore KarmaStore;
    mapping(address => mapping(address => bool)) public optedOut;
    mapping(address => bool) public optedOutAll;
    event karmaUpdated(address app, address user, int amount);

    constructor() {
        admin = msg.sender;
    }

    modifier isAdmin(address sender) {
        require(sender == admin, "Sender must be Karma admin");
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
    returns (uint256 karma) {
        KarmaStruct memory karmaObject = KarmaStore.readKarma(appAddr, addr);
        karma = karmaObject.value;
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
    notOptOut(msg.sender, addr)
    {
        KarmaStruct memory karma = KarmaStore.readKarma(msg.sender, addr);
        if (updateFunctionKey == 1) {
            updateByAdd(msg.sender, addr, karma, amount);
        } else if (updateFunctionKey == 2) {
            updateByAvg(msg.sender, addr, karma, amount);
        } else {
            revert("updateFunctionKey is not valid");
        }
    }

    /**
    * @dev Function used to update karma through a weighted sum
    * @param appAddr  The address of the application updating karma
    * @param addr  The address of the user whose karma is being updated
    * @param karma  The karma object of a user for a given contract address
    * @param update The amount used to calculate how much should be added or removed from
                    a user's karma value. If the amount is positive, it will increase the 
                    user's karma. If it is negative, it will decrease it. 
    **/
    function updateByAdd(address appAddr, address addr, KarmaStruct memory karma, int update) 
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
            KarmaStore.writeKarma(appAddr, addr, karma.value, karma.metadata);
        } else {
            karma.value = tentativeValue;
            KarmaStore.writeKarma(appAddr, addr, karma.value, karma.metadata);
        }
    }

    /**
    * @dev Function used to update karma through an averaged sum
    * @param appAddr The address of the application updating karma
    * @param addr  The address of the user whose karma is being updated
    * @param karma  The karma object of a user for a given contract address
    * @param update The amount used to calculate how much should be added or removed from
                    a user's karma value. If the amount is positive, it will increase the 
                    user's karma. If it is negative, it will decrease it. 
    **/
    function updateByAvg(address appAddr, address addr, KarmaStruct memory karma, int update) 
    internal 
    {
        uint[] memory metadata = karma.metadata;
        if (metadata.length == 0) {
            metadata = new uint[](5);
        }
        metadata[0] = metadata[0] + 1;
        int diff = update - int(karma.value);
        int tentativeValue = int(karma.value) + (diff / int(metadata[0]));    
        if (tentativeValue < 0) {
            KarmaStore.writeKarma(appAddr, addr, 0, metadata);
        } else {
            karma.value = uint(tentativeValue);
            KarmaStore.writeKarma(appAddr, addr, karma.value, metadata);
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
        optedOut[appAddr][msg.sender] = true;
    }

    /**
    * @dev Function used to opt out of karma tracking for all applications
    **/
    function optOutAll() 
    external {
        optedOutAll[msg.sender] = true;
    }

    /**
    * @dev Function to instantiate KarmaStore contract
    * @param karmaStoreAddress Address of the KarmaStore contract
    **/
    function setKarmaStore(address karmaStoreAddress)
    external
    isAdmin(msg.sender)
    {
        KarmaStore = InterfaceKarmaStore(karmaStoreAddress);
    }

    /**
    * @dev Function to set the address of the contract admin
    * @param newAdminAddress The address of the new Karma admin
    **/
    function setAdminAddress(address newAdminAddress)
    external
    isAdmin(msg.sender)
    {
        admin = newAdminAddress;
    }
}
