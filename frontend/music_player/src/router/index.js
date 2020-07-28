import Vue from 'vue'
import VueRouter from 'vue-router'
import Login from "../components/Login.vue"
import index from '../components/index.vue';

Vue.use(VueRouter)

  const routes = [
	{
		path: "/",
		component:index
		// redirect: "/login"
	},
	{
		path: "/login",
		component: Login
	}
]

const router = new VueRouter({
  routes
})

export default router
