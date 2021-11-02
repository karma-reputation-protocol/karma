# Karma Protocol

Karma enables dApps to keep a ledger of user integrity. The dApp is free to decide based on what behavior karma should be generated or destroyed for its users. By keeping a ledger of user reputation with the Karma protocol, dApps can leverage it to access global reputation scores of unknown users. With this information the dApp can effectively integrate new users within the existing reputation network.

## Using Karma in your dApp

Virtually no setup is required. To start tracking the behavior of your app's users with Karma, simply call the updateKarma() method of the Karma contract with the desired user's address and the value you want to add to their Karma. Now, when you call getKarma() for that user's address, the Karma contract will return the user's updated karma value. (Note: Karma is initially set to 0 for all users and cannot become negative).

## Updating your users karma

To increase a user's karma, call the updateKarma function with a positive value. To lower a user's karma, call the updateKarma function with a negative karma value.

There are currently two ways to update a user's karma value. The first is by weighted addition with frequency decay. In this method, karma is added to the user's current karma value. This is best suited for financial applications that want to keep a credit score of their users as the frequency decay prevents scores from bloating and loosing meaning. The second method for updating karma is by using an averaging function. In this method, a user's karma value is the average of all previous update values. This is best suited for applications that want to track user ratings, such as ecommerce applications.

## Opting out

If a user wishes to opt out of being tracked, they must call either the optOut(addrress) or optOutAll() methods of the Karma contract. The optOut(address) method will block future updates to their karma value for the application deployed at the address specified and set it to 0. The optOutAll() will block future updates to the user's karma across all applications. In both cases, a getKarma() call for the user will result in a revert.

## Karma deployment details:

### Celo Network

#### Main net

{INSERT ADDRESS HERE}

#### Alfajores

{INSERT ADDRESS HERE}
