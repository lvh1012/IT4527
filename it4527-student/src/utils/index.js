import Web3 from 'web3';
import axios from 'axios';

export const getWeb3 = () => {
    return new Web3("https://data-seed-prebsc-1-s1.binance.org:8545/");
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