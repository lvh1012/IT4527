import Vue from 'vue'
import VueRouter from 'vue-router'
import FindCertificate from '@/components/FindCertificate.vue'
import VerifyCertificate from '@/components/VerifyCertificate.vue'

Vue.use(VueRouter)

export const router = new VueRouter({
    routes: [
        { path: '/', redirect: { name: 'find-certificate' } },
        { path: '/find-certificate', component: FindCertificate, name: 'find-certificate' },
        { path: '/verify-certificate', component: VerifyCertificate, name: 'verify-certificate' },
    ]
})