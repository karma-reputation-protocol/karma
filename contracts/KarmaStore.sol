// SPDX-License-Identifier: MIT
pragma solidity 0.8;

interface InterfaceKarmaStore {
    function readKarma(address appAddr, address addr) external view returns (KarmaStruct memory karma);
    function writeKarma(address addr, KarmaStruct memory newKarma) external payable;
}

struct KarmaStruct {
    uint value;  
    uint[] metadata;  
}

contract KarmaStore {

    mapping(address => mapping(address => KarmaStruct)) public karmaMap;
    address karmaAddress;
    address admin;

    constructor() {
        admin = msg.sender;
    }

    modifier isKarma(address sender) {
        require(sender == karmaAddress, "Function can only be called from the Karma contract");
        _;
    }

    modifier isAdmin(address sender) {
        require(sender == admin, "Sender must be KarmaStore admin");
        _;
    }

    /**
    * @dev Function to read the karma value for a user. 
    * @param appAddr The address of the app for which karma is being is being read
    * @param addr The address of the user whose karma is being read
    **/
    function readKarma(address appAddr, address addr) 
    external 
    view
    isKarma(msg.sender)
    returns (KarmaStruct memory karma) {
        karma = karmaMap[appAddr][addr];
    }

    /**
    * @dev Function to write over a user's karma value for a specified application
    * @param appAddr The address of the app for which karma is being is being overwritten
    * @param addr The address of the user whose karma is being overwritten
    * @param value The value that the user's karma will be set to
    * @param metadata Additional values used in karma calculation
    **/
    function writeKarma(address appAddr, address addr, uint value, uint[] calldata metadata) 
    isKarma(msg.sender)
    external  
    {
        karmaMap[appAddr][addr].value = value;
        karmaMap[appAddr][addr].metadata = metadata;
    }

    /**
    * @dev Function to set the address of the Karma contract
    * @param newKarmaAddress The address of the Karma contract
    **/
    function setKarmaAddress(address newKarmaAddress)
    external
    isAdmin(msg.sender)
    {
        karmaAddress = newKarmaAddress;
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
