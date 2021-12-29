<template>
   
    <div class="cert__verify d-flex">
        <div class="col-8 verify__left d-flex flex-column py-0" >
            <div class="d-flex flex-row font-weight-bold border-bottom">
                <div class="p-2 col-1">Code</div>
                <div class="p-2 col-4">Name</div>
                <div class="p-2 col-6">Address</div>
                <div class="p-2 col-1"></div>
            </div>
            <div class="d-flex flex-row border-bottom" v-for="admin in admins" v-bind:key="admin.id">
                <div class="p-2 col-1">{{admin.code}}</div>
                <div class="p-2 col-4">{{admin.name}}</div>
                <div class="p-2 col-6">{{admin._address}}</div>
                <div v-if="admin.code!='root'" style="cursor: pointer" @click="$bvModal.show('bv-modal-delete'); adminId = parseInt(admin.id)" class="p-2 col-1 d-flex justify-content-end align-items-center"><b-icon icon="trash-fill" aria-hidden="true"></b-icon></div>
                <div v-else class="p-2 col-1"></div>
            </div>
        </div>
        <div class="col-4 verify__right d-flex flex-column align-items-center">
            <b-form class="col" @submit="onSubmit" @reset="onReset">
                <b-form-group id="input-group-0" label="Code:" label-for="input-0">
                    <b-form-input
                    id="input-0"
                    v-model="form.code"
                    placeholder="AD001"
                    required
                    ></b-form-input>
                </b-form-group>
                <b-form-group id="input-group-1" label="Name:" label-for="input-1">
                    <b-form-input
                    id="input-1"
                    v-model="form.name"
                    placeholder="Admin"
                    required
                    ></b-form-input>
                </b-form-group>

                <b-form-group id="input-group-2" label="Address:" label-for="input-2">
                    <b-form-input
                    id="input-2"
                    v-model="form._address"
                    placeholder="0x984e0Bf009D6371Ae25063D0FD7503357D48dc05"
                    required
                    ></b-form-input>
                </b-form-group>              

                <b-button v-if="!processing" type="submit" variant="success">Add</b-button>
                <b-button v-else disabled type="submit" variant="success">
                    <b-spinner small type="grow"></b-spinner>
                    Adding...                 
                </b-button>
                <b-button class="mx-4" type="reset">Reset</b-button>
                </b-form>
        </div>

                      <b-modal id="bv-modal-delete" hide-footer>
                        <template #modal-title>
                        Delete issuer
                        </template>
                        <div class="d-block text-center">
                        Are you sure you want to remove this issuer?
                        </div>
                        <b-button v-if="!processingDelete" class="mt-3 float-right" variant="success" @click="deleteAdmin">Delete</b-button>
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

export default {
  data() {
    return {
        processing: false,
        processingDelete: false,
        adminId: 0,
        form: {
            id: '',
            code: '',
            name: '',
            _address: '',
        },
        admins: new Array()
    }
  },
    computed: { ...mapState(["account", "contract"]) },
    mounted (){
            if (this.contract) {
                this.getAdmins();
            }
    },
    watch: {
        contract(newValue, oldValue) {
            console.log(`Updating from ${oldValue} to ${newValue}`);

            // Do whatever makes sense now
            if (newValue) {
                this.getAdmins();
            }
        },
    },
  methods: {
    ...mapActions(["onLoading", "offLoading"]),
    onReset: function(){
        this.form = {
            id: '',
            code: '',
            name: '',
            _address: '',
        }
    },
    getAdmins: function() {
        const _this = this;
        this.onLoading();
        this.contract.methods.getAdmins().call()
        .then(function(result){
            _this.admins = [...result];
            _this.offLoading();
        });
    },
    onSubmit: function(event) {
        event.preventDefault()

        if (!this.contract){
            this.$bvToast.toast('Please connect Metamask', {
                title: `Error`,
                variant: 'danger',
                solid: true,
                autoHideDelay: 2000,
            })
            return
        }

        try {
            this.processing = true;
            this.onLoading();
            this.form.id = parseInt(new Date().getTime()/1000);
            const _this=this;
            this.contract.methods.addAdmin(this.form.id, this.form.code, this.form.name, this.form._address).send({from: this.account, gas:3000000})
            .on('receipt', function(receipt){
                    _this.$bvToast.toast(`transactionHash: ${receipt.transactionHash}`, {
                    title: `Add issuer`,
                    variant: 'success',
                    solid: true,
                    autoHideDelay: 2000,
                })

                _this.processing = false;
                _this.offLoading();

                _this.admins.push({..._this.form});
            })
            .on('error', function(error, receipt) { // If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
                    _this.$bvToast.toast('Issuer is invalid', {
                        title: `Error`,
                        variant: 'danger',
                        solid: true,
                        autoHideDelay: 2000,
                    })

                _this.processing = false;
                _this.offLoading();
            })            
        } catch (error) {
            this.$bvToast.toast(error.message, {
                title: `Error`,
                variant: 'danger',
                solid: true,
                autoHideDelay: 2000,
            })
            this.processing = false;
            this.offLoading();
        }

        

    },
    deleteAdmin: function(){
        const _this = this;
        this.processingDelete=true;
        this.contract.methods.deleteAdminById(this.adminId).send({from: this.account, gas:3000000})
        .on('receipt', function(receipt){
            _this.$bvToast.toast(`transactionHash: ${receipt.transactionHash}`, {
                title: `Deleted`,
                variant: 'success',
                solid: true,
                autoHideDelay: 2000,
            })

            _this.$bvModal.hide('bv-modal-delete')
            _this.processingDelete=false;

            const adminId = _this.adminId
            _this.admins = _this.admins.filter(admin => parseInt(admin.id) != parseInt(adminId));
        })
        .on('error', function(error, receipt) { // If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
            _this.$bvToast.toast('Something Went Wrong', {
                title: `Error`,
                variant: 'danger',
                solid: true,
                autoHideDelay: 2000,
            })
            _this.$bvModal.hide('bv-modal-delete')
            _this.processingDelete=false;
        });
    }
  }
};
</script>

<style scoped>
.border-bottom{
    border-bottom: 1px solid #212F3D !important;
}

.verify__left{
    overflow: auto;
}
</style>
