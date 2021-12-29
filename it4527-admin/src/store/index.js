import Vue from 'vue';
import Vuex from 'vuex';
import {getWeb3} from '@/utils';
import {abi, contractAddress} from './smartcontract';

Vue.use(Vuex);

export default new Vuex.Store({
    state: { web3: null, account: null, contract: null, loading: false, accounts: []  },
    mutations: {
        setWeb3(state, payload) {
            state.web3 = payload.web3;
        },
        setAccount(state, payload) {
            state.account = payload.account;
        },
		setAccounts(state, payload) {
            state.accounts = payload.accounts;
        },
        setContract(state, payload) {
            state.contract = payload.contract;
        },
        setLoading(state, payload) {
            state.loading = payload.loading;
        }
    },
    actions: {
        async setWeb3({ commit }) {
            const web3 = await getWeb3();
            if (web3) {
                const accounts = await web3.eth.getAccounts();
                if (accounts.length > 0) {
                    const account = accounts[0];
                    commit('setWeb3', { web3: web3 });
                    commit('setAccount', { account: account }); 
					commit('setAccounts', { accounts: accounts }); 
					// commit('setAccount', { account: '0x955F45F304897F72729B0096aBFd40cBA2ef1Fa0' });
                    commit('setContract', { contract : new web3.eth.Contract(abi, contractAddress)})
                } else {
                    console.log('Account not found');
                }
            }
        },
        removeWeb3({ commit }) {
            commit('setWeb3', { web3: null });
            commit('setAccount', { account: null });
        },
		onLoading({commit}){
			commit('setLoading', { loading: true });
		},
		offLoading({commit}){
			commit('setLoading', { loading: false });
		},
		setAccount({commit}, newAccount){
			commit('setAccount', { account: newAccount });
		},
		setAccounts({commit}, accounts){
			commit('setAccounts', { accounts: accounts });
		}
    },
    getters: {}
});