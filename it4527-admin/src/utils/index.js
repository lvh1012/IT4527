import Web3 from 'web3';
import axios from 'axios';

export const getWeb3 = async () => {
    if (window.ethereum) {
        try {
            // Request account access if needed
            await window.ethereum.enable();
            // Acccounts now exposed
            try {
                await window.ethereum.request({
                    method: 'wallet_switchEthereumChain',
                    params: [{ chainId: '0x61' }],
                });

                const web3 = new Web3(window.ethereum);
                return web3;
            } catch (switchError) {
                // This error code indicates that the chain has not been added to MetaMask.
                if (switchError.code === 4902) {
                    try {
                        await window.ethereum.request({
                            method: 'wallet_addEthereumChain',
                            params: [{ "chainId": "0x61", "chainName": "Smart Chain - Testnet", "rpcUrls": ["https://data-seed-prebsc-1-s1.binance.org:8545/"], "nativeCurrency": { "name": "Smart Chain - Testnet", "symbol": "BNB", "decimals": 18 } }]
                        });
                        // const web3 = new Web3("https://data-seed-prebsc-1-s1.binance.org:8545/");
                        // return web3;
                        const web3 = new Web3(window.ethereum);
                        return web3;
                    } catch (addError) {
                        // handle "add" error
                    }
                }
                // handle other "switch" errors
            }
        } catch (error) {
            console.error(error);
        }
    }
    else {
        return null;
    }

    // console.log('No web3 instance injected, using Local web3.');
    // return new Web3("ws://localhost:8545");
};

export const unpinFile = (cid) => {
    const url = "https://api.pinata.cloud/pinning/unpin/" + cid;
    axios.delete(url, {
        headers: {
            pinata_api_key: process.env.VUE_APP_API_KEY,
            pinata_secret_api_key: process.env.VUE_APP_API_SECRET
        }
    })
        .then(function (res) {
            console.log("unpin successfully")
        })
        .catch(function (error) {
            console.log("unpin failed")
        })
};