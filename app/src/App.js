import React, { useEffect, useState } from "react";
import './styles/App.css';
import twitterLogo from './assets/twitter-logo.svg';
import threeWordsGif from './assets/three-words.gif';
import { ethers } from 'ethers';
import myEpicNft from './utils/myEpicNft.json';

const TWITTER_HANDLE = '_buildspace';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
// const OPENSEA_LINK = '';
// const TOTAL_MINT_COUNT = 250;

const App = () => {
  const [currentAccount, setCurrentAccount] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccessfulMint, setIsSuccessfulMint] = useState(false);
  const [etherscanLink, setEtherscanLink] = useState('');

  const checkIfWalletIsConnected = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      console.log("Make sure you have metamask!");
      return;
    } else {
      console.log("We have the ethereum object", ethereum);
    }

    const accounts = await ethereum.request({ method: 'eth_accounts' });

    if (accounts.length !== 0) {
      const account = accounts[0];
      console.log("Found an authorized account:", account);
      setCurrentAccount(account)
    } else {
      console.log("No authorized account found")
    }
  }

  /*
  * Implement your connectWallet method here
  */
  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get MetaMask!");
        return;
      }

      /*
      * Fancy method to request access to account.
      */
      const accounts = await ethereum.request({ method: "eth_requestAccounts" });

      /*
      * Boom! This should print out public address once we authorize Metamask.
      */
      console.log("Connected", accounts[0]);
      setCurrentAccount(accounts[0]);
    } catch (error) {
      console.log(error)
    }
  }

  const askContractToMintNft = async () => {
    const CONTRACT_ADDRESS = "0xf5abcfdefc91cb865d6f3a458f6ceeee8871ec1b"; // @TODO: Update this anytime a new contract is deployed && update the abi file(src/utils/myEpicNft.json) 
    setIsSuccessfulMint(false);

    try {
      const { ethereum } = window;

      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const connectedContract = new ethers.Contract(CONTRACT_ADDRESS, myEpicNft.abi, signer);

        console.log("Going to pop wallet now to pay gas...")
        let nftTxn = await connectedContract.makeAnEpicNFT();
        setIsLoading(true);

        console.log("Mining...please wait.")
        await nftTxn.wait();
        setIsLoading(false);
        setIsSuccessfulMint(true);

        setEtherscanLink(`https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);
        console.log(`Mined, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);

      } else {
        console.log("Ethereum object doesn't exist!");
      }
    } catch (error) {
      console.log(error)
    }
  }

  const getButton = () => {
    if (currentAccount === "") {
      return (<button onClick={connectWallet} className="cta-button connect-wallet-button">
        Connect to Wallet
      </button>)
    } return (<button onClick={askContractToMintNft} className="cta-button connect-wallet-button">
      {isLoading ? 'Minting...' : 'Mint NFT'}
    </button>)

  };

  useEffect(() => {
    checkIfWalletIsConnected();
  }, [])

  /*
  * Added a conditional render! We don't want to show Connect to Wallet if we're already connected :).
  */
  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">TheseThreeWords NFT</p>
          <p className="sub-text">
            Each unique. Each beautiful. Mint your NFT today.
          </p>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
          <img src={threeWordsGif} alt={'3 Words Gif'} className="three-words-gif" />
          {/* <p className="mint-count">{currentMintCount}/{TOTAL_MINT_COUNT}</p> */}
          {getButton()}
          {currentAccount !== "" && (<p className="wallet-address-text">{currentAccount} is connected!</p>)}
          {isSuccessfulMint && (
            <p className="success-message">Successful Mint! See your transaction here: <a className="etherscan-link" href={etherscanLink}>Etherscan</a></p>
          )}
        </div>
        <div className="footer-container">
          <img alt="Twitter Logo" className="twitter-logo" src={twitterLogo} />
          <a
            className="footer-text"
            href={TWITTER_LINK}
            target="_blank"
            rel="noreferrer"
          >{`built on @${TWITTER_HANDLE}`}</a>
        </div>
      </div>
    </div>
  );
};

export default App;
