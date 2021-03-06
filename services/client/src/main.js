import Vue from 'vue'
import App from './App.vue'
import router from './router'
import vuetify from './plugins/vuetify';
import vueDebounce from 'vue-debounce'

import Breadcrumbs from '@/components/Breadcrumbs';
Vue.component('Breadcrumbs', Breadcrumbs);

Vue.config.productionTip = false
Vue.use(vueDebounce, { fireOnEmpty: true });

new Vue({
  router,
  vuetify,
  render: h => h(App)
}).$mount('#app')
