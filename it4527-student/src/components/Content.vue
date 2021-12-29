<template>
  <div>
    <div class="_navbar side d-flex">
        <router-link  class="no-link cert col d-flex align-items-center justify-content-center border-left border-right" :class="{selected: $route.name == 'find-certificate'}" :to="{name: 'find-certificate'}">
            <div>Find Certificate </div>
        </router-link>

        <router-link  class="cert no-link col d-flex align-items-center justify-content-center border-left border-right" :class="{selected: $route.name == 'verify-certificate'}" :to="{name: 'verify-certificate'}">
            <div>Verify Certificate</div>
        </router-link>
        
    </div>
    <div class="content side" >
        <router-view/>
       <div :class="{none: !loading}" class="loading">
           <b-spinner class="spinner" label="Loading..."></b-spinner>
       </div>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";

export default {
  data() {
    return {

    }
  },
  computed: { ...mapState(["loading"]) },
    mounted() {

    },
  methods: {
  }
};
</script>

<style>
.loading{
    width:100vw; 
    height:calc(100vh - 15rem); 
    position: absolute; 
    opacity: 0.8; 
    background-color:#D5D8DC;
    top: 0;
    left: 0;
    color: black;
}

.spinner{
width: 10rem !important;
 height: 10rem !important;
  position: absolute; 
  top: calc(50% - 5rem);
  left: calc(50% - 5rem);
}

.none{
    display: none !important;
}

._navbar {
  height: 3rem;
  background-color: #363636;
  color: white;
}

.content {
  height: calc(100vh - 15rem);
  background-color: #fff;
  position: relative;
}

.cert{
    font-weight: 600;
    height: inherit;
}

.selected{
    background-color: #be0f0f;
}

.content{
    padding-top:1rem;
    padding-bottom: 1rem;
}

.cert__find{
    height: 3rem;
    margin-bottom: 0.5rem;
}

.cert__result{
    height: 100%;
    overflow: auto;
    color: black
}

.cert__verify{
    height: 100%;
    color:black;
}

.verify__left{
    background-color: #E5E8E8;
    border-radius: 0.5rem;
    padding: 2rem 1rem !important;
}

.verify__left__uploadbox{
    width: 100%;
    height: 100%;
    border: .5rem dashed #424949;
    border-radius: 0.5rem;
}
.img-wrap{
    height: 100%;
    width: 100%;
    position: relative;
    padding: 1rem;
}

.img-wrap .delete-img {
    position: absolute;
    top: 2px;
    right: 2px;
    z-index: 100;
    cursor: pointer;
}

.img-preview{
    width: 100%;
    height: 100%; 
    object-fit: contain;
}

.no-link{
    color: white !important;
    text-decoration: none !important;
}
</style>
