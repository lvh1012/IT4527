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
        <div class="col-6 verify__right d-flex flex-column align-items-center">
            <b-form class="col" @submit="onSubmit" @reset="onReset">
                <b-form-group id="input-group-0" label="Code:" label-for="input-0">
                    <b-form-input
                    id="input-0"
                    v-model="form.code"
                    placeholder="HV001"
                    required
                    ></b-form-input>
                </b-form-group>
                <b-form-group id="input-group-1" label="Name:" label-for="input-1">
                    <b-form-input
                    id="input-1"
                    v-model="form.name"
                    placeholder="Lê Viết Hoàng"
                    required
                    ></b-form-input>
                </b-form-group>                

                <b-button v-if="!processing" type="submit" variant="success">Add</b-button>
                <b-button v-else disabled type="submit" variant="success">
                    <b-spinner small type="grow"></b-spinner>
                    Adding...                 
                </b-button>
                <b-button class="mx-4" type="reset">Reset</b-button>

        <router-link :to="{name: 'list-certificate', params: {id: courseId, course: currentCourse}}">
            <b-button class="float-right" variant="link">List Certificate 	&#8594;</b-button>
        </router-link>
                
                </b-form>
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
        courseId: 0,
        form: {
            id: '',
            code: '',
            name: '',
        },
        currentCourse: {
            code: "",
            name: ""
        }
    }
  },
    computed: { ...mapState(["account", "web3", "contract"]) },
    mounted() {
        this.currentCourse = Object.assign(this.currentCourse, this.$route.params.course);
        this.courseId = parseInt(this.$route.params.id);
    },
  methods: {
    ...mapActions(["onLoading", "offLoading"]),
    onFileChange: function(e) {
      this.file = e.target.files[0];
      this.url = URL.createObjectURL(this.file);
    },
    deleteImg : function(){
        this.url = null
        this.file = null
    },
    onReset: function(){
        this.url = null,
        this.file = null,
        this.form = {
            id: '',
            code: '',
            name: ''
        }
    },
    onSubmit: function(event) {
        event.preventDefault()
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
        

        this.form.id = parseInt(new Date().getTime()/1000);
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
            _this.contract.methods.addCertificate(_this.form.id, _this.courseId, _this.form.id,_this.form.code,_this.form.name, ipfsHash).send({from: _this.account, gas:3000000})
            .on('receipt', function(receipt){
                     _this.$bvToast.toast(`transactionHash: ${receipt.transactionHash}`, {
                        title: `Add cert`,
                        variant: 'success',
                        solid: true,
                        autoHideDelay: 2000,
                    })

                _this.processing = false;
                _this.offLoading();
            })
            .on('error', function(error, receipt) { // If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
                    _this.$bvToast.toast('Certificate is invalid', {
                        title: `Error`,
                        variant: 'danger',
                        solid: true,
                        autoHideDelay: 2000,
                    })

                    _this.processing = false;
                    _this.offLoading();
                    if (reason !== 'The certificate already exists'){
                        unpinFile(ipfsHash)
                    }
            });
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

</style>
