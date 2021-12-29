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
export default {
  components: {
    Header,
    Content,
    Footer,
  },
  name: "main-content",
};
</script>