<template>
  <div style="width:100%; height: calc(100% - 3.5rem);">
        <div class="cert__find d-flex justify-content-center align-items-center" style="color: black; font-size: 2rem;">
            <strong>{{currentCourse.code}} : {{currentCourse.name}}</strong>
        </div>
        <div class="cert__find d-flex">
            <div class=" col-10">
                <b-form-input v-model="search" placeholder="Search Certificate by id"></b-form-input>
            </div>
            <div class=" col-2">
                <b-button block variant="success">
                    Search
                </b-button>
            </div>
        </div>

        <div class="cert__result">
            <div style="height:3rem">
                <router-link :to="{name: 'add-certificate', params: {id: courseId, course: currentCourse}}">
                    <b-button class="float-right" variant="link">Add Certificate &#8594;</b-button>
                </router-link>
            </div>
            <div class="d-flex flex-column" style="height: calc(100% - 6rem);overflow: auto;">
            <div style="height:13rem" class="p-2 py-4 border-bottom d-flex flex-row align-items-start" v-for="(certificate, index) in filteredCertificate" v-bind:key="certificate.id">
                <div class="px-2 col-4">
                    <b-img center :src="`https://gateway.pinata.cloud/ipfs/${certificate.ipfsHash}`"></b-img>
                </div>
                <div class="px-2 col-6 d-flex flex-column">
                    <div class="p-2 text-truncate">
                        <strong>Certificate ID:</strong> {{certificate.id}}
                    </div>
                    <div class="p-2 text-truncate">
                        <strong>Student Code:</strong> {{students[index].code}}
                    </div>
                    <div class="p-2 text-truncate">
                        <strong>Student Name:</strong> {{students[index].name}}
                    </div>
                    <div class="p-2 text-truncate">
                        <b-link :href="`https://gateway.pinata.cloud/ipfs/${certificate.ipfsHash}`" target="_blank">Link certificate</b-link>
                    </div>
                </div>
                <div class="px-2 col-2 d-flex flex-column justify-content-between">

                    <b-button @click="$bvModal.show('bv-modal-delete'); certificateId = parseInt(certificate.id); selectedIndex = index">Delete</b-button>
                </div>
            </div>          
        </div>
  </div>
                      <b-modal id="bv-modal-delete" hide-footer>
                        <template #modal-title>
                        Delete certificate
                        </template>
                        <div class="d-block text-center">
                        Are you sure you want to remove this certificate?
                        </div>
                        <b-button v-if="!processingDelete" class="mt-3 float-right" variant="success" @click="deleteCertificate">Delete</b-button>
                        <b-button v-else class="mt-3 float-right" disabled variant="success">
                            <b-spinner small type="grow"></b-spinner>
                            Deleting...   
                        </b-button>
                        <b-button class="mt-3 mx-3 float-right" @click="$bvModal.hide('bv-modal-delete')">Cancel</b-button>
                    </b-modal>
  </div>
</template>

<script>
import { mapState, mapActions } from "vuex";
import {unpinFile} from '@/utils';

export default {
  data() {
    return {
        certificates : new Array(),
        students: new Array(),
        courseId : 0,
        certificateId: 0,
        selectedIndex: 0,
        processing: false,
        processingDelete: false,
        search: '',
        currentCourse: {
            code: "",
            name: ""
        }
    }
  },
    computed: { ...mapState(["account", "contract"]),
    filteredCertificate: function (){
        return this.certificates.filter(certificate => {
            return certificate.id.toString().toLowerCase().includes(this.search.toLowerCase())
        })
    }
    },
    mounted() {
        this.currentCourse = Object.assign(this.currentCourse, this.$route.params.course);
        this.courseId = parseInt(this.$route.params.id);
            if (this.contract) {
                this.getCertificates();
            }
    },
    watch: {
        contract(newValue, oldValue) {
            console.log(`Updating from ${oldValue} to ${newValue}`);

            // Do whatever makes sense now
            if (newValue) {
                this.getCertificates();
            }
        },
    },
  methods: {
      ...mapActions(["onLoading", "offLoading"]),

    getCertificates: function() {
        const _this = this;
        this.onLoading();
        this.contract.methods.getCertificateOfCourse(this.courseId).call()
        .then(function(result){
            _this.students = [... result[0]].reverse();
            _this.certificates = [... result[1]].reverse();
            _this.offLoading();
        });
    },
    deleteCertificate: function(){
        this.processingDelete = true;
        const _this = this;
        this.contract.methods.deleteCertificateById(this.certificateId).send({from: this.account, gas:3000000})
        .on('receipt', function(receipt){
            _this.$bvToast.toast(`transactionHash: ${receipt.transactionHash}`, {
                title: `Deleted`,
                variant: 'success',
                solid: true,
                autoHideDelay: 2000,
            })
            const ipfsHash = _this.certificates[_this.selectedIndex].ipfsHash;
            _this.$bvModal.hide('bv-modal-delete')
            _this.processingDelete = false;
            _this.certificates.splice(_this.selectedIndex, 1);
            _this.students.splice(_this.selectedIndex, 1);
            unpinFile(ipfsHash)
        })
        .on('error', function(error, receipt) { // If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
            _this.$bvToast.toast('Something Went Wrong', {
                title: `Error`,
                variant: 'danger',
                solid: true,
                autoHideDelay: 2000,
            })
            _this.$bvModal.hide('bv-modal-delete')
            _this.processingDelete = false;
        });
    }
  }
};
</script>

<style scoped>
img{
    max-width: 100%;
    max-height: 10rem;
}
</style>
