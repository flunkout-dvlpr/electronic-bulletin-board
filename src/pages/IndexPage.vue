<template>
  <q-page class="flex flex-center">
    <div class="text-center">
      <div class="q-mb-lg">
        <q-icon name="dashboard" size="150px" color="primary" />
      </div>
      
      <h2 class="text-h3 q-mb-md">Digital Bulletin Board</h2>
      
      <p class="text-h6 text-grey-7 q-mb-lg">
        A modern solution for publishing city meeting agendas
      </p>

      <div class="q-gutter-md">
        <q-btn
          push
          color="primary"
          size="lg"
          label="View Public Board"
          to="/board"
          icon="visibility"
        />
        
        <q-btn
          push
          color="secondary"
          size="lg"
          label="Staff Login"
          to="/login"
          icon="login"
        />
      </div>

      <div class="q-mt-xl text-grey-6">
        <p>
          <q-icon name="info" class="q-mr-sm" />
          All meeting agendas are posted at least 48 hours before meetings
        </p>
      </div>
    </div>
  </q-page>
</template>

<script>
import { defineComponent } from 'vue'

export default defineComponent({
  name: 'IndexPage'
})
</script>