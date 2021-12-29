import Vue from 'vue'
import VueRouter from 'vue-router'
import ListCourse from '@/components/ListCourse.vue'
import ListCertificate from '@/components/ListCertificate.vue'
import AddCourse from '@/components/AddCourse.vue'
import EditCourse from '@/components/EditCourse.vue'
import AddCertificate from '@/components/AddCertificate.vue'
import AddIssuer from '@/components/AddIssuer.vue'

Vue.use(VueRouter)

export const router = new VueRouter({
    routes: [
        { path: '/', redirect: { name: 'list-course' } },
        { path: '/list-course', component: ListCourse, name: 'list-course' },
        { path: '/list-certificate/:id', component: ListCertificate, name: 'list-certificate' },
        { path: '/add-course', component: AddCourse, name: 'add-course' },
        { path: '/edit-course', component: EditCourse, name: 'edit-course' },
        { path: '/add-certificate/:id', component: AddCertificate, name: 'add-certificate' },
        { path: '/add-issuer', component: AddIssuer, name: 'add-issuer' },
    ]
})