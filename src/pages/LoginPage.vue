<template>
  <q-page class="flex flex-center">
    <div class="q-pa-md" style="max-width: 400px; width: 100%;">
      <q-card>
        <q-card-section class="text-center">
          <div class="text-h4 q-mb-md">Staff Login</div>
          <div class="text-grey-7">
            Access your department's agenda management
          </div>
        </q-card-section>

        <q-card-section>
          <q-form @submit="handleLogin" class="q-gutter-md">
            <q-input
              v-model="email"
              type="email"
              label="Email"
              outlined
              :rules="[val => !!val || 'Email is required']"
              lazy-rules
            >
              <template v-slot:prepend>
                <q-icon name="person" />
              </template>
            </q-input>

            <q-input
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              label="Password"
              outlined
              :rules="[val => !!val || 'Password is required']"
              lazy-rules
            >
              <template v-slot:prepend>
                <q-icon name="lock" />
              </template>
              <template v-slot:append>
                <q-icon
                  :name="showPassword ? 'visibility' : 'visibility_off'"
                  class="cursor-pointer"
                  @click="showPassword = !showPassword"
                />
              </template>
            </q-input>

            <q-select
              v-model="selectedDepartment"
              :options="departments"
              label="Department"
              outlined
              :rules="[val => !!val || 'Department is required']"
              lazy-rules
            >
              <template v-slot:prepend>
                <q-icon name="business" />
              </template>
            </q-select>

            <div class="q-mt-lg">
              <q-btn
                type="submit"
                color="primary"
                size="lg"
                label="Sign In"
                :loading="loading"
                class="full-width"
              />
            </div>
          </q-form>
        </q-card-section>

        <q-card-section class="text-center">
          <div class="text-caption text-grey-6">
            Need help accessing your account?<br>
            Contact IT Support: support@city.gov
          </div>
        </q-card-section>
      </q-card>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'

export default defineComponent({
  name: 'LoginPage',

  setup() {
    const $q = useQuasar()
    const router = useRouter()

    const email = ref('')
    const password = ref('')
    const selectedDepartment = ref(null)
    const showPassword = ref(false)
    const loading = ref(false)

    const departments = [
      'City Council',
      'Planning Department',
      'Parks & Recreation',
      'Public Works',
      'Fire Department',
      'Police Department',
      'Finance Department',
      'Human Resources'
    ]

    const handleLogin = async () => {
      loading.value = true

      try {
        // Simulate API call delay
        await new Promise(resolve => setTimeout(resolve, 1000))

        // Mock authentication - in real app, this would call AWS Cognito
        if (email.value && password.value && selectedDepartment.value) {
          // Store user info (in real app, use proper auth store)
          const userInfo = {
            email: email.value,
            department: selectedDepartment.value,
            role: email.value.includes('admin') ? 'admin' : 'staff',
            loginTime: new Date().toISOString()
          }

          localStorage.setItem('userInfo', JSON.stringify(userInfo))

          $q.notify({
            type: 'positive',
            message: 'Login successful!',
            position: 'top'
          })

          // Redirect based on role
          if (userInfo.role === 'admin') {
            router.push('/admin')
          } else {
            router.push('/staff')
          }
        } else {
          throw new Error('Invalid credentials')
        }
      } catch (error) {
        $q.notify({
          type: 'negative',
          message: 'Login failed. Please check your credentials.',
          position: 'top'
        })
      } finally {
        loading.value = false
      }
    }

    return {
      email,
      password,
      selectedDepartment,
      showPassword,
      loading,
      departments,
      handleLogin
    }
  }
})
</script>