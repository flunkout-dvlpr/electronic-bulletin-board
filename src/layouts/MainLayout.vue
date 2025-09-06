<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated>
      <q-toolbar>
        <q-btn
          flat
          dense
          round
          icon="menu"
          aria-label="Menu"
          @click="toggleLeftDrawer"
        />

        <q-toolbar-title> Digital Bulletin Board </q-toolbar-title>

        <div class="row items-center q-gutter-md">
          <q-btn flat label="Public Board" to="/board" />
          <q-btn flat label="Staff Login" to="/login" />
          <ThemeToggle flat color="white" />
        </div>
      </q-toolbar>
    </q-header>

    <q-drawer v-model="leftDrawerOpen" bordered>
      <q-list>
        <q-item-label header> Navigation </q-item-label>

        <EssentialLink
          v-for="link in essentialLinks"
          :key="link.title"
          v-bind="link"
        />
      </q-list>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script>
import { defineComponent, ref, onMounted, getCurrentInstance } from "vue";
import EssentialLink from "components/EssentialLink.vue";
import ThemeToggle from "components/ThemeToggle.vue";

const linksList = [
  {
    title: "Home",
    caption: "Welcome page",
    icon: "home",
    link: "/",
  },
  {
    title: "Public Board",
    caption: "View all agendas",
    icon: "dashboard",
    link: "/board",
  },
  {
    title: "Staff Login",
    caption: "Upload agendas",
    icon: "login",
    link: "/login",
  },
];

export default defineComponent({
  name: "MainLayout",

  components: {
    EssentialLink,
    ThemeToggle,
  },

  setup() {
    const leftDrawerOpen = ref(false);
    const instance = getCurrentInstance();

    onMounted(() => {
      // Initialize Quasar dark mode based on system preference
      const prefersDark = window.matchMedia(
        "(prefers-color-scheme: dark)"
      ).matches;
      const savedMode = localStorage.getItem("q-dark-mode");

      if (savedMode !== null) {
        // Use saved preference
        instance.proxy.$q.dark.set(savedMode === "true");
      } else {
        // Use system preference
        instance.proxy.$q.dark.set(prefersDark);
      }
    });

    return {
      essentialLinks: linksList,
      leftDrawerOpen,
      toggleLeftDrawer() {
        leftDrawerOpen.value = !leftDrawerOpen.value;
      },
    };
  },
});
</script>
