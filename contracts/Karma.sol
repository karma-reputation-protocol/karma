// SPDX-License-Identifier: MIT
pragma solidity 0.8;

struct KarmaStruct {
    uint value;  
    uint[] metadata;  
}

contract Karma {
    mapping(address => mapping(address => KarmaStruct)) public karmaMap;
    mapping(address => mapping(address => bool)) public optedOut;
    mapping(address => bool) public optedOutAll;

    event karmaUpdated(address app, address user, int amount);

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
    * @param addr The address of the user whose karma is being accessed
    **/
    function getKarma(address addr) 
    external 
    view 
    notOptOut(msg.sender, addr)
    returns (uint karma) {
        karma = karmaMap[msg.sender][addr].value;
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
        KarmaStruct storage karma = karmaMap[msg.sender][addr];
        if (karma.metadata.length == 0) {
            karma.metadata = new uint[](5);
        }
        if (updateFunctionKey == 1) {
            updateByAdd(karma, amount);
        } else if (updateFunctionKey == 2) {
            updateByAvg(karma, amount);
        } else {
            revert("updateFunctionKey is not valid");
        }
        emit karmaUpdated(msg.sender, addr, amount);
    }

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

        if (update < 0) {
            uint tentativeValue = log2(uint(update*-1));
            if (tentativeValue > karma.value) {
                karma.value = 0;
            } else {
                karma.value -= tentativeValue;
            }
            
        } else {
            karma.value += log2(uint(update));
        }
    }

    function log2(uint x) 
    internal 
    pure 
    returns (uint y){
        assembly {
            let arg := x
            x := sub(x,1)
            x := or(x, div(x, 0x02))
            x := or(x, div(x, 0x04))
            x := or(x, div(x, 0x10))
            x := or(x, div(x, 0x100))
            x := or(x, div(x, 0x10000))
            x := or(x, div(x, 0x100000000))
            x := or(x, div(x, 0x10000000000000000))
            x := or(x, div(x, 0x100000000000000000000000000000000))
            x := add(x, 1)
            let m := mload(0x40)
            mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
            mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
            mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
            mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
            mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
            mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
            mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
            mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
            mstore(0x40, add(m, 0x100))
            let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
            let shift := 0x100000000000000000000000000000000000000000000000000000000000000
            let a := div(mul(x, magic), shift)
            y := div(mload(add(m,sub(255,a))), shift)
            y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
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
        karma.metadata[0] += 1;
        int diff = update - int(karma.value);
        int tentativeValue = int(karma.value) + (diff / int(karma.metadata[0]));    
        if (tentativeValue < 0) {
            karma.value = 0;
        } else {
            karma.value = uint(tentativeValue);
        }
    }

    /**
    * @dev Function used to opt out of karma tracking for a specified application
    * @param appAddr  The address of the application for which the sender wants to opt out. 
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
