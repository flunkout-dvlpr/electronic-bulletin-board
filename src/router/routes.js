const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', component: () => import('pages/IndexPage.vue') },
      { path: '/board', component: () => import('pages/BulletinBoard.vue') },
      { path: '/login', component: () => import('pages/LoginPage.vue') },
      { path: '/staff', component: () => import('pages/StaffDashboard.vue') },
      { path: '/admin', component: () => import('pages/AdminDashboard.vue') }
    ]
  },

  // Always leave this as last one,
  // but you can also remove it
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue')
  }
]

export default routes