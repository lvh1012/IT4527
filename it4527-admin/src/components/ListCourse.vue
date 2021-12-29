<template>
  <div style="width:100%; height: calc(100% - 3.5rem);">
        <div class="cert__find d-flex">
            <div class=" col-10">
                <b-form-input v-model="search" placeholder="Search Course by Code"></b-form-input>
            </div>
            <div class=" col-2">
                <b-button block variant="success">
                    Search
                </b-button>
            </div>
        </div>
        <div class="cert__result">
            <div class="d-flex flex-column">
            <div style="height:13rem" class="p-2 py-4 border-bottom d-flex flex-row align-items-start" v-for="(course, index) in filteredCourse" v-bind:key="course.id">
                <div class="px-2 col-3">
                    <router-link :to="{name: 'list-certificate', params: {id: course.id, course: course}}">
                        <b-img center :src="`https://gateway.pinata.cloud/ipfs/${course.ipfsHash}`"></b-img>
                    </router-link>
                    
                    <!-- <img :src="`https://gateway.pinata.cloud/ipfs/${course.ipfsHash}`"> -->
                </div>
                <div class="px-2 col-6 d-flex flex-column">
                    <div class="p-2 text-truncate">
                        <strong>Code:</strong> {{course.code}}
                    </div>
                    <div class="p-2 text-truncate">
                        <strong>Name:</strong> {{course.name}}
                    </div>
                    <div class="p-2 text-truncate">
                        <strong>Date:</strong> {{course.date}}
                    </div>
                    <div class="p-2 text-truncate">
                        <strong>Issued by:</strong> {{course.issuer}}
                    </div>
                </div>
                <div class="px-2 col-2 d-flex align-self-center">
                    <router-link  :to="{name: 'add-certificate', params:{ id: course.id, course: course }}">
                        <b-button variant="success">Add Certificate</b-button>
                    </router-link>  
                </div>
                <div class="px-2 col-1 d-flex align-items-start justify-content-end">
                    <b-dropdown variant="outline-secondary" size="sm" no-caret style="color: black">
                        <template #button-content>
                        <b-icon icon="three-dots-vertical" aria-hidden="true"></b-icon>
                        </template>
  
                        <b-dropdown-item @click="$router.push({name: 'edit-course', params:{ course }})">Edit</b-dropdown-item>
                        <b-dropdown-item @click="$bvModal.show('bv-modal-delete'); courseId = parseInt(course.id); selectedIndex = index">Delete</b-dropdown-item>
                    </b-dropdown>
                </div>
            </div>          
        </div>
  </div>
                      <b-modal id="bv-modal-delete" hide-footer>
                        <template #modal-title>
                        Delete course
                        </template>
                        <div class="d-block text-center">
                        Are you sure you want to remove this course?
                        </div>
                        <b-button v-if="!processingDelete" class="mt-3 float-right" variant="success" @click="deleteCourse">Delete</b-button>
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
        courses : new Array(),
        courseId : 0,
        selectedIndex: 0,
        processing: false,
        processingDelete: false,
        search: '',
    }
  },
    computed: { ...mapState(["account", "contract"]),
    filteredCourse: function (){
        return this.courses.filter(course => {
            return course.code.toLowerCase().includes(this.search.toLowerCase())
        })
    }
    
    },
    mounted() {
            if (this.contract) {
                this.getCourses();
            }
    },
    watch: {
        contract(newValue, oldValue) {
            console.log(`Updating from ${oldValue} to ${newValue}`);

            // Do whatever makes sense now
            if (newValue) {
                this.getCourses();
            }
        },
    },
  methods: {
      ...mapActions(["onLoading", "offLoading", "setWeb3"]),

    getCourses: function() {
        const _this = this;
        this.onLoading();
        this.contract.methods.getCourses().call()
        .then(function(result){
            _this.courses = [...result].reverse();
             _this.offLoading();
        });
    },
    deleteCourse: function(){
        this.processingDelete = true;
        const _this = this;
        this.contract.methods.deleteCourseById(this.courseId).send({from: this.account, gas:3000000})
        .on('receipt', function(receipt){
            _this.$bvToast.toast(`transactionHash: ${receipt.transactionHash}`, {
                title: `Deleted`,
                variant: 'success',
                solid: true,
                autoHideDelay: 2000,
            })
            
            _this.$bvModal.hide('bv-modal-delete')
            _this.processingDelete = false;

            const ipfsHash = _this.courses[_this.selectedIndex].ipfsHash;
            const courseId = _this.courseId
            _this.courses = _this.courses.filter(course => parseInt(course.id) != parseInt(courseId));
            unpinFile(ipfsHash);
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
