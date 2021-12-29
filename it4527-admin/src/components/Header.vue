<template>
  <header id="header" class="w-100 side d-flex d-flex align-items-center justify-content-between">
    <img class="logo col-3" src="@/assets/logo.png" />
    <div class="d-flex flex-column col-6">
      <div class="uppercase black bold">Đại học Bách khoa hà nội</div>
      <div class="uppercase black bold">TRƯỜNG CÔNG NGHỆ THÔNG TIN VÀ TRUYỀN THÔNG</div>
    </div>
    <div class="col-3 d-flex align-items-center justify-content-end">
      <b-button v-if="!account" variant="success" @click="setWeb3">
        <b-icon icon="link-45deg"></b-icon>
        Connect Wallet
      </b-button>
      <b-dropdown v-else split variant="success" right text="Right align" no-caret>
        <template #button-content style="background-color: #be0f0f">
          <b-icon icon="link-45deg"></b-icon>  
          {{`Connecting ${account.substring(0, 10)}...`}}
        </template>
        <b-dropdown-item v-for="(acc, index) in accounts" v-bind:key="index" @click="setAccount(acc)">{{acc}}</b-dropdown-item>
      </b-dropdown>      
    </div>
  </header>
</template>

<script>
import { mapActions, mapState } from "vuex";
export default {
  data() {
    return {};
  },
  computed: { ...mapState(["account", "accounts"]) },
  methods: {
    ...mapActions(["setAccount", "setWeb3"]),
  },
};
</script>

<style>
#header {
  height: 6rem;
}

.logo {
  height: 5rem;
  margin: 0.5rem;
}

.uppercase {
  text-transform: uppercase;
}

.bold {
  font-weight: bold;
  letter-spacing: 0.05em;
  line-height: 1.5;
}

.black{
    color: black;
}
</style>
