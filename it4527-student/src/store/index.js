import Vue from 'vue';
import Vuex from 'vuex';
import { getWeb3 } from '@/utils';
import {abi, contractAddress} from './smartcontract.js'

Vue.use(Vuex);

export default new Vuex.Store({
	state: { account: null, contract: null, loading: false },
	mutations: {
		setAccount(state, payload) {
			state.account = payload.account;
		},
		setContract(state, payload) {
			state.contract = payload.contract;
		},
		setLoading(state, payload) {
			state.loading = payload.loading;
		}
	},
	actions: {
		setWeb3({ commit }) {
			const web3 = getWeb3();
			const account = web3.eth.accounts.create().address;
			const contract = new web3.eth.Contract(abi, contractAddress);
			commit('setAccount', { account: account });
			commit('setContract', { contract: contract})
		},
		onLoading({ commit }) {
			commit('setLoading', { loading: true });
		},
		offLoading({ commit }) {
			commit('setLoading', { loading: false });
		}
	},
	getters: {}
});