module.exports = {
  title: 'Wiredash SDK',
  description: 'Get started with the Wiredash SDK!',
    themeConfig: {
        displayAllHeaders: true,
        nav: [
            { text: 'Home', link: '/' },
            { text: 'Get Started', link: '/guide/' },
            { text: 'Configuration', link: '/configuration/' },
            { text: 'Admin Console', link: 'https://console.wiredash.io' }
        ],
        searchPlaceholder: 'Search...',
        sidebarDepth: 2,
        sidebar: [
            '/guide/',
            '/configuration/'
        ],
        repo: 'wiredashio/wiredash-sdk',
        docsDir: 'docs',
        docsBranch: 'master',
        editLinks: true,
        editLinkText: 'Help us improve this page!'
    }
}
