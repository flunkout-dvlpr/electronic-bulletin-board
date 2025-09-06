const { configure } = require('quasar/wrappers');

module.exports = configure(function (/* ctx */) {
  return {
    boot: [
      'axios',
    ],

    css: [
      'app.scss'
    ],

    extras: [
      'roboto-font',
      'material-icons',
    ],

    build: {
      vueRouterMode: 'hash'
    },

    devServer: {
      open: true
    },

    framework: {
      config: {
        brand: {
          primary: '#324D9C',
          secondary: '#B5792D',
          accent: '#FFD328',
          dark: '#795830',
          positive: '#21BA45',
          negative: '#C10015',
          info: '#324D9C',
          warning: '#B5792D'
        }
      },
      plugins: [
        'Notify',
        'Dialog',
        'Loading'
      ]
    }
  }
});