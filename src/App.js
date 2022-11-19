import logo from './logo.svg';
import { useEffect, useState } from 'react';
import './App.css';
import { ethers } from 'ethers';
import BadgeABI from './utils/BadgeABI.json';
import { BADGE_CONTRACT_ADDRESS } from './utils/constants';

function App () {
  const [account, setAccount] = useState(null)
  const [nfts, setNfts] = useState([])
  const connectWallet = async () => {
    try {
      const { ethereum } = window;
      if (!ethereum) {
        alert('Get MetaMask!');
        return;
      }
      const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
      console.log('account', accounts[0]);
      setAccount(accounts[0]);
      const provider = new ethers.providers.JsonRpcProvider("https://wallaby.node.glif.io/rpc/v0");
      const contract = new ethers.Contract(BADGE_CONTRACT_ADDRESS, BadgeABI, provider);
      // const balance = await contract.balanceOf(accounts[0]);
      // const tokenId = await contract.addressToTokenIds(accounts[0])
      const allTokens = await contract.getAllTokenIdsOfAddress(accounts[0]);
      console.log('allTokens', allTokens);
      // console.log('tokenId', parseInt(tokenId));
      if (allTokens.length > 0) {
        let nftdata = [];
        for (let i = 0; i < allTokens.length; i++) {
          const tokenURI = await contract.getTokenURI(allTokens[i]);
          const json = atob(tokenURI.substring(29));
          const result = JSON.parse(json);
          console.log('tokenURI', result);
          nftdata.push(result);
        }
        setNfts(nftdata);
      }
    } catch (error) {
      console.log(error);
    }
  }

  useEffect(() => {
    connectWallet();
  }, [])

  return (
    <div className="App">
      {/* simple navbar */}
      <nav className="navbar navbar-expand-lg navbar-light bg-light">
        <div className="container-fluid">
          {account ? null : <button onClick={connectWallet}>Connect Wallet</button>}
        </div>
      </nav>
      <div className="container">
        <div className="row">
          <div className="col-12">
            <h1 className="text-center">NFT List</h1>
            {nfts.map((nft, i) => (
              // <div key={i} className="card" >
              <img key={i} src={nft.image} style={{ height: 400, width: 400, margin: 10 }} className="img-fluid" />
              // </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
