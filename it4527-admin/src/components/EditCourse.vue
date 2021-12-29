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
            <b-form class="col" @submit="onSubmit">
                <b-form-group id="input-group-0" label="Code:" label-for="input-0">
                    <b-form-input
                    id="input-0"
                    v-model="form.code"
                    placeholder="IT4527"
                    required
                    ></b-form-input>
                </b-form-group>
                <b-form-group id="input-group-1" label="Name:" label-for="input-1">
                    <b-form-input
                    id="input-1"
                    v-model="form.name"
                    placeholder="Blockchain & Application"
                    required
                    ></b-form-input>
                </b-form-group>

                <b-form-group id="input-group-3" label="Date:" label-for="input-3">
                    <b-form-input
                    id="input-3"
                    v-model="form.date"
                    placeholder="01/01/2021 - 12/12/2021"
                    required
                    ></b-form-input>
                </b-form-group>

                <b-form-group id="input-group-4" label="Issued by:" label-for="input-4">
                    <b-form-input
                    id="input-4"
                    v-model="form.issuer"
                    placeholder="TS. TRẦN VĨNH ĐỨC"
                    required
                    ></b-form-input>
                </b-form-group>                    

                <b-button v-if="!processing" type="submit" variant="success">Save</b-button>
                <b-button v-else disabled type="submit" variant="success">
                    <b-spinner small type="grow"></b-spinner>
                    Saving...                 
                </b-button>
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
            date: '',
            issuer: ''
        },
    }
  },
    computed: { ...mapState(["account", "contract"]) },
    mounted() {
        let data = this.$route.params.course;
        this.form = {...data};
        this.url = `https://gateway.pinata.cloud/ipfs/${data.ipfsHash}`;
    },
  methods: {
    ...mapActions(["onLoading", "offLoading"]),
    onFileChange: function(e) {
      this.file = e.target.files[0];
      this.url = URL.createObjectURL(this.file);
    },
    deleteImg : function(){
        this.url = null;
        this.file = null;
    },
    onSubmit: function(event) {
        event.preventDefault()
        // khong thay anh moi
        if (!this.file && this.url){
            this.processing = true;
            this.onLoading();
            const _this = this;
            this.contract.methods.setCourseById(this.form.id, this.form.code, this.form.name, this.form.date, this.form.issuer, this.form.ipfsHash).send({from: this.account, gas:3000000})
            .on('receipt', function(receipt){
                     _this.$bvToast.toast(`transactionHash: ${receipt.transactionHash}`, {
                        title: `Updated`,
                        variant: 'success',
                        solid: true,
                        autoHideDelay: 2000,
                    })
                    _this.processing = false;
                    _this.offLoading();
                    // this.$router.push({ name: 'list-course'})
                    return;
            })
            .on('error', function(error, receipt) { // If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
                   _this.$bvToast.toast('Course is invalid', {
                        title: `Error`,
                        variant: 'danger',
                        solid: true,
                        autoHideDelay: 2000,
                    })

                    _this.processing = false;
                    _this.offLoading();
                    // this.$router.push({ name: 'list-course'})
                    return;
            });
        }

        if (!this.file && !this.url){
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
        

        this.form.id = parseInt(this.form.id);
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
            _this.contract.methods.setCourseById(_this.form.id, _this.form.code, _this.form.name, _this.form.date, _this.form.issuer, ipfsHash).send({from: _this.account, gas:3000000})
            .on('receipt', function(receipt){
                     _this.$bvToast.toast(`transactionHash: ${receipt.transactionHash}`, {
                        title: `Updated`,
                        variant: 'success',
                        solid: true,
                        autoHideDelay: 2000,
                    })
                _this.processing = false;
                _this.offLoading();
                unpinFile(_this.form.ipfsHash);
            })
            .on('error', function(error, receipt) { // If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
                _this.$bvToast.toast('Course is invalid', {
                    title: `Error`,
                    variant: 'danger',
                    solid: true,
                    autoHideDelay: 2000,
                })
                _this.processing = false;
                _this.offLoading();
                unpinFile(ipfsHash);
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
