# Renown-ity

## Reputation System to track the on-chain activity of a user via granting upgradable NFTs.

### How to run?

- Step 1: Clone the repo and install the dependencies
- Step 2: Deploy the contracts on the wallaby network using Remix IDE for ease of use.
- Step 3: Take note of the contract address and replace the address in the `src/utils/constants.js` file.
- Step 4: Run `npm start` to start the app.

You would have no nfts in your wallet. So, you can mint some nfts by heading over to Remix IDE and entering the name as anything you want and supply your wallet address, then click on the mint button.
Once the transaction goes through, refresh the page and you would see the nfts.
You can mint multiple nfts with different names.

To upgrade the nfts, simply use the train method of the smart contract and supply a new name to the nft just the way you minted it. As soon as the transaction is completed, refresh the page and you would see the upgraded nft with a different level field.
