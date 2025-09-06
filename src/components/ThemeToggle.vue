<template>
  <q-btn
    :icon="$q.dark.isActive ? 'light_mode' : 'dark_mode'"
    :label="showLabel ? ($q.dark.isActive ? 'Light Mode' : 'Dark Mode') : ''"
    @click="toggleDarkMode"
    :flat="flat"
    :outline="outline"
    :round="round"
    :size="size"
    :color="color || 'primary'"
    :title="$q.dark.isActive ? 'Switch to Light Mode' : 'Switch to Dark Mode'"
  />
</template>

<script>
import { defineComponent } from "vue";

export default defineComponent({
  name: "ThemeToggle",

  props: {
    showLabel: {
      type: Boolean,
      default: false,
    },
    flat: {
      type: Boolean,
      default: false,
    },
    outline: {
      type: Boolean,
      default: false,
    },
    round: {
      type: Boolean,
      default: false,
    },
    size: {
      type: String,
      default: "md",
    },
    color: {
      type: String,
      default: null,
    },
  },

  methods: {
    toggleDarkMode() {
      this.$q.dark.toggle();
      // Save to localStorage
      localStorage.setItem("q-dark-mode", this.$q.dark.isActive);
    },
  },
});
</script>
