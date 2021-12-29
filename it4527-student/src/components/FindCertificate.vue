<template>
  <div style="width:100%; height: calc(100% - 3.5rem);">
        <div class="cert__find d-flex">
            <div class=" col-10">
                <b-form-input type="number" v-model="search" placeholder="Search Certificate By ID"></b-form-input>
            </div>
            <div class=" col-2">
                <b-button v-if="!processing" block variant="success" @click="getCertificateById">
                    Search
                </b-button>
                <b-button v-else  disabled variant="success">
                    <b-spinner small type="grow"></b-spinner>
                    Searching...   
                </b-button>
            </div>
        </div>
        <div class="cert__result d-flex p-2 justify-content-center">
            <template v-if="afterSearching&&result">
                <div class="px-2 col-6">
                    <img :src="`https://gateway.pinata.cloud/ipfs/${certificate.ipfsHash}`">
                </div>
                <div class="px-2 col-6 d-flex flex-column">
                    <div style="font-size:2rem" class="p-4 d-flex justify-content-center font-weight-bold">
                        CERTIFICATE INFORMATION
                        
                    </div>
                    <div class="d-flex">
                        <div class="col-6 d-flex flex-column">
                            <div class="p-2 text-truncate">
                                <strong>Course Code:</strong> {{course.code}}
                            </div>
                            <div class="p-2 text-truncate">
                                <strong>Course Name:</strong> {{course.name}}
                            </div>
                            <div class="p-2 text-truncate">
                                <strong>Date:</strong> {{course.date}}
                            </div>
                            <div class="p-2 text-truncate">
                                <strong>Issued by:</strong> {{course.issuer}}
                            </div>
                        </div> 
                        <div class="col-6 d-flex flex-column">
                            <div class="p-2 text-truncate">
                                <strong>Certificate ID:</strong> {{certificate.id}}
                            </div>
                            <div class="p-2 text-truncate">
                                <strong>Student Code:</strong> {{student.code}}
                            </div>
                            <div class="p-2 text-truncate">
                                <strong>Student Name:</strong> {{student.name}}
                            </div>
                            <div class="p-2 text-truncate">
                                <b-link :href="`https://gateway.pinata.cloud/ipfs/${certificate.ipfsHash}`" target="_blank">Link certificate</b-link>
                            </div>
                        </div> 
                    </div>

                </div>                 
            </template>
            <template v-else-if="afterSearching&&!result">
                <img src="@/assets/no-result.jpg" alt="">
            </template>
      
        </div>
  </div>
  </div>
</template>

<script>
import { mapState, mapActions } from "vuex";

export default {
  data() {
    return {
        certificate : null,
        student: null,
        course: null,
        processing: false,
        search: null,
        result: false,
        afterSearching: false
    }
  },
    computed: { ...mapState(["account","contract"]) },
    methods: {
      ...mapActions(["onLoading", "offLoading"]),

    getCertificateById: function() {
        if (!this.search){
            this.$bvToast.toast('Please enter certificate ID', {
                title: `Error`,
                variant: 'danger',
                solid: true,
                autoHideDelay: 2000,
            })
            return
        }
        const _this = this;
        this.onLoading();
        this.contract.methods.getCertificateById(parseInt(this.search)).call()
        .then(function(result){
            _this.certificate = result[0];
            _this.course = result[1];
            _this.student = result[2];
            _this.result = parseInt(_this.certificate.id) != 0;
            _this.afterSearching = true;
            _this.offLoading();
        });
        
    }
  }
};
</script>

<style scoped>
img{
    max-width: 100%;
    max-height: 100%;
}
</style>
