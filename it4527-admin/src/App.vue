<template>
  <div id="app">
    <Main />
  </div>
</template>

<script>
import Main from "./components/Main.vue";

export default {
  name: "App",
  components: {
    Main,
  }
};
</script>

<style>
.side {
  padding-left: 8rem;
  padding-right: 8rem;
}
#app {
  color: white;
}

.btn-success {
  background-color: #be0f0f !important;
  border-color: #be0f0f !important;
}
.btn:focus {
  outline: none !important;
  box-shadow: none !important;
}
</style>
