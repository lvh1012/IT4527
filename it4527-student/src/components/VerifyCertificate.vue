<template>
   
    <div class="cert__verify d-flex">
        <div class="col-6 verify__left" >
            <div class="verify__left__uploadbox d-flex align-items-center justify-content-center">
                <div v-if="url" class="img-wrap">
                        <b-icon icon="x" class="border border-danger rounded delete-img" variant="danger" font-scale="2" @click="deleteImg"></b-icon>
                    <img class="img-preview"  :src="url" />
                </div>
                
                <label v-else for="upload" class="d-flex flex-column justify-content-center">
                    <span class="d-flex justify-content-center">
                        <b-icon icon="cloud-upload-fill" style="width: 6rem; height: 6rem; cursor: pointer" ></b-icon>
                    </span>
                    <strong class="d-flex justify-content-center">Choose an image</strong>
                    <input required type="file" id="upload" style="display:none" @change="onFileChange">
                </label>
            </div>
        </div>
        <div class="col-6 verify__right d-flex flex-column">
            <div class="p-2 d-flex flex-row justify-content-center">
                <b-button style="padding: 1rem 8rem; font-weight: 600;" v-if="!processing" @click="verifyCertificate" variant="success">Verify</b-button>
                <b-button style="padding: 1rem 8rem; font-weight: 600;" v-else disabled variant="success">
                    <b-spinner small type="grow"></b-spinner>
                    Verifying...                 
                </b-button>
            </div>
            <div class="p-5 d-flex flex-column align-items-center justify-content-center">
                <transition name="fade">
                <div class=" d-flex flex-column align-items-center justify-content-center" v-if="afterSearching&&!result">
                    <b-icon icon="x-octagon-fill" class="text-danger p-2" style="width:8rem; height: 8rem"></b-icon>
                    <strong class="p-2">Certificate is not valid</strong>
                </div>
                <div class=" d-flex flex-column align-items-center justify-content-center" v-if="afterSearching&&result">
                     <b-icon icon="shield-fill-check" class="text-success p-2" style="width:8rem; height: 8rem"></b-icon>
                    <strong class="p-2">Verification Success</strong>
                </div>
                </transition>
            </div>
        </div>
    </div> 

</template>

<script>
import { mapState, mapActions } from "vuex";
import axios from 'axios';
import {unpinFile} from '@/utils';

export default {
  data() {
    return {
        url: null,
        file: null,
        processing: false,
        result: false,
        afterSearching: false
    }
  },
    computed: { ...mapState(["account","contract"]) },
  methods: {
    ...mapActions(["onLoading", "offLoading"]),
    onFileChange: function(e) {
      this.file = e.target.files[0];
      this.url = URL.createObjectURL(this.file);
    },
    deleteImg : function(){
        this.url = null;
        this.file = null;
        this.result = false;
        this.afterSearching = false;
    },
    verifyCertificate: async function(event) {
        if (!this.file){
            this.$bvToast.toast('Please choose an image', {
                title: `Error`,
                variant: 'danger',
                solid: true,
                autoHideDelay: 2000,
            })
            return;
        }

        this.processing = true;
        this.onLoading();
        const data = new FormData();
        data.append('file', this.file);

        const _this = this;
        axios.post(`https://api.pinata.cloud/pinning/pinFileToIPFS`, data, {
            maxBodyLength: 'Infinity', //this is needed to prevent axios from erroring out with large directories
            headers: {
                'Content-Type': `multipart/form-data; boundary=${data._boundary}`,
                pinata_api_key: process.env.VUE_APP_API_KEY,
                pinata_secret_api_key: process.env.VUE_APP_API_SECRET
            }
        })
        .then(function (response) {
            const ipfsHash = response.data.IpfsHash;
            _this.contract.methods.verifyCertificate(ipfsHash).call()
            .then(function(result){
                _this.result = result;
                _this.afterSearching = true;
            });
            _this.processing = false;
            _this.offLoading();

            if(!_this.result){
                unpinFile(ipfsHash);
            }
        })
        .catch(function (error) {
            _this.$bvToast.toast(error.message, {
                title: `Error`,
                variant: 'danger',
                solid: true,
                autoHideDelay: 2000,
            })
            _this.processing = false;
            _this.offLoading();
        });
    },
  }
};
</script>

<style scoped>
.fade-enter-active, .fade-leave-active {
  transition: opacity .5s;
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}
</style>
