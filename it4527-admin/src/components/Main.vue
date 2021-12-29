<template>
  <div>
    <Header></Header>
    <Content></Content>
    <Footer></Footer>
  </div>
</template>

<script>
import Header from "./Header";
import Content from "./Content";
import Footer from "./Footer";
import { mapState, mapActions } from "vuex";
export default {
  components: {
    Header,
    Content,
    Footer,
  },
  name: "main-content",
  computed: {
    ...mapState(["web3"]),
  },
  created: function () {
    ethereum.on("accountsChanged", (accounts) => {
      this.setAccount(accounts[0]);
      this.setAccounts(accounts);
    });
  },
  methods:{
    ...mapActions(["setAccount","setAccounts"])
  },
  watch: {
    web3(newValue, oldValue) {
      console.log(`Updating from ${oldValue} to ${newValue}`);

      // Do whatever makes sense now
      if (newValue) {
        this.$bvToast.toast("Connected Metamask", {
          title: `Success`,
          variant: "success",
          solid: true,
          autoHideDelay: 2000,
        });
      }
    },
  },
};
</script>