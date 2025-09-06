<template>
  <q-page class="q-pa-md">
    <div class="row q-mb-lg items-center justify-between">
      <div class="col">
        <h3 class="text-h4 q-my-none">Admin Dashboard</h3>
        <div class="text-grey-7">
          System Administrator | {{ userInfo?.email }}
        </div>
      </div>
      <div class="col-auto">
        <q-btn
          color="negative"
          label="Logout"
          icon="logout"
          @click="logout"
          outline
        />
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="row q-gutter-lg q-mb-lg">
      <div class="col-md-3 col-sm-6 col-xs-12">
        <q-card class="text-center">
          <q-card-section>
            <q-icon name="pending" size="40px" color="orange" />
            <div class="text-h4 q-mt-sm">{{ stats.pending }}</div>
            <div class="text-grey-7">Pending Review</div>
          </q-card-section>
        </q-card>
      </div>
      
      <div class="col-md-3 col-sm-6 col-xs-12">
        <q-card class="text-center">
          <q-card-section>
            <q-icon name="published_with_changes" size="40px" color="green" />
            <div class="text-h4 q-mt-sm">{{ stats.published }}</div>
            <div class="text-grey-7">Published</div>
          </q-card-section>
        </q-card>
      </div>
      
      <div class="col-md-3 col-sm-6 col-xs-12">
        <q-card class="text-center">
          <q-card-section>
            <q-icon name="people" size="40px" color="blue" />
            <div class="text-h4 q-mt-sm">{{ stats.departments }}</div>
            <div class="text-grey-7">Departments</div>
          </q-card-section>
        </q-card>
      </div>
      
      <div class="col-md-3 col-sm-6 col-xs-12">
        <q-card class="text-center">
          <q-card-section>
            <q-icon name="warning" size="40px" color="red" />
            <div class="text-h4 q-mt-sm">{{ stats.violations }}</div>
            <div class="text-grey-7">Compliance Issues</div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Main Content Tabs -->
    <q-card>
      <q-tabs
        v-model="activeTab"
        class="text-grey"
        active-color="primary"
        indicator-color="primary"
        align="justify"
        narrow-indicator
      >
        <q-tab name="pending" label="Pending Review" icon="pending" />
        <q-tab name="published" label="Published" icon="visibility" />
        <q-tab name="users" label="User Management" icon="people" />
        <q-tab name="audit" label="Audit Log" icon="history" />
      </q-tabs>

      <q-separator />

      <q-tab-panels v-model="activeTab" animated>
        <!-- Pending Review Tab -->
        <q-tab-panel name="pending">
          <div class="text-h6 q-mb-md">Pending Agenda Reviews</div>
          
          <q-table
            :rows="pendingAgendas"
            :columns="pendingColumns"
            row-key="id"
            flat
          >
            <template v-slot:body-cell-actions="props">
              <q-td :props="props">
                <div class="q-gutter-xs">
                  <q-btn
                    flat
                    round
                    icon="visibility"
                    size="sm"
                    @click="viewDocument(props.row)"
                  />
                  <q-btn
                    flat
                    round
                    icon="check"
                    color="green"
                    size="sm"
                    @click="approveAgenda(props.row)"
                  />
                  <q-btn
                    flat
                    round
                    icon="close"
                    color="red"
                    size="sm"
                    @click="rejectAgenda(props.row)"
                  />
                </div>
              </q-td>
            </template>
          </q-table>
        </q-tab-panel>

        <!-- Published Tab -->
        <q-tab-panel name="published">
          <div class="text-h6 q-mb-md">Published Agendas</div>
          
          <q-table
            :rows="publishedAgendas"
            :columns="publishedColumns"
            row-key="id"
            flat
          >
            <template v-slot:body-cell-actions="props">
              <q-td :props="props">
                <div class="q-gutter-xs">
                  <q-btn
                    flat
                    round
                    icon="visibility"
                    size="sm"
                    @click="viewDocument(props.row)"
                  />
                  <q-btn
                    flat
                    round
                    icon="unpublished"
                    color="orange"
                    size="sm"
                    @click="unpublishAgenda(props.row)"
                  />
                  <q-btn
                    flat
                    round
                    icon="archive"
                    color="grey"
                    size="sm"
                    @click="archiveAgenda(props.row)"
                  />
                </div>
              </q-td>
            </template>
          </q-table>
        </q-tab-panel>

        <!-- User Management Tab -->
        <q-tab-panel name="users">
          <div class="row items-center justify-between q-mb-md">
            <div class="text-h6">User Management</div>
            <q-btn
              color="primary"
              label="Add User"
              icon="person_add"
              @click="showAddUserDialog = true"
            />
          </div>
          
          <q-table
            :rows="users"
            :columns="userColumns"
            row-key="id"
            flat
          >
            <template v-slot:body-cell-status="props">
              <q-td :props="props">
                <q-badge
                  :color="props.row.active ? 'green' : 'red'"
                  :label="props.row.active ? 'Active' : 'Inactive'"
                />
              </q-td>
            </template>
            
            <template v-slot:body-cell-actions="props">
              <q-td :props="props">
                <div class="q-gutter-xs">
                  <q-btn
                    flat
                    round
                    icon="edit"
                    size="sm"
                    @click="editUser(props.row)"
                  />
                  <q-btn
                    flat
                    round
                    :icon="props.row.active ? 'person_off' : 'person'"
                    :color="props.row.active ? 'red' : 'green'"
                    size="sm"
                    @click="toggleUserStatus(props.row)"
                  />
                </div>
              </q-td>
            </template>
          </q-table>
        </q-tab-panel>

        <!-- Audit Log Tab -->
        <q-tab-panel name="audit">
          <div class="text-h6 q-mb-md">System Audit Log</div>
          
          <q-table
            :rows="auditLog"
            :columns="auditColumns"
            row-key="id"
            flat
          >
            <template v-slot:body-cell-action="props">
              <q-td :props="props">
                <q-badge
                  :color="getActionColor(props.row.action)"
                  :label="props.row.action"
                />
              </q-td>
            </template>
          </q-table>
        </q-tab-panel>
      </q-tab-panels>
    </q-card>

    <!-- Add User Dialog -->
    <q-dialog v-model="showAddUserDialog">
      <q-card style="min-width: 400px">
        <q-card-section>
          <div class="text-h6">Add New User</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-form class="q-gutter-md">
            <q-input v-model="newUser.email" label="Email" outlined />
            <q-input v-model="newUser.name" label="Full Name" outlined />
            <q-select v-model="newUser.department" :options="departmentOptions" label="Department" outlined />
            <q-select v-model="newUser.role" :options="roleOptions" label="Role" outlined />
          </q-form>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup />
          <q-btn flat label="Create User" color="primary" @click="createUser" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script>
import { defineComponent, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'

export default defineComponent({
  name: 'AdminDashboard',

  setup() {
    const $q = useQuasar()
    const router = useRouter()

    const userInfo = ref(null)
    const activeTab = ref('pending')
    const showAddUserDialog = ref(false)

    const stats = ref({
      pending: 3,
      published: 12,
      departments: 6,
      violations: 1
    })

    const newUser = ref({
      email: '',
      name: '',
      department: '',
      role: ''
    })

    // Mock data
    const pendingAgendas = ref([
      {
        id: 1,
        title: 'Special Budget Review',
        department: 'Finance Department',
        submittedBy: 'jane.doe@city.gov',
        submittedDate: '2025-09-10T14:30:00',
        meetingDate: '2025-09-20T19:00:00'
      },
      {
        id: 2,
        title: 'Zoning Variance Hearing',
        department: 'Planning Department',
        submittedBy: 'john.smith@city.gov',
        submittedDate: '2025-09-09T11:15:00',
        meetingDate: '2025-09-18T18:30:00'
      }
    ])

    const publishedAgendas = ref([
      {
        id: 1,
        title: 'City Council Regular Meeting',
        department: 'City Council',
        publishedDate: '2025-09-08T10:00:00',
        meetingDate: '2025-09-10T19:00:00',
        archiveDate: '2025-09-12T19:00:00',
        autoArchive: true,
        views: 156
      }
    ])

    const users = ref([
      {
        id: 1,
        name: 'Jane Doe',
        email: 'jane.doe@city.gov',
        department: 'Finance Department',
        role: 'Staff',
        active: true,
        lastLogin: '2025-09-10T09:30:00'
      },
      {
        id: 2,
        name: 'John Smith',
        email: 'john.smith@city.gov',
        department: 'Planning Department',
        role: 'Staff',
        active: true,
        lastLogin: '2025-09-09T14:15:00'
      }
    ])

    const auditLog = ref([
      {
        id: 1,
        timestamp: '2025-09-10T15:30:00',
        user: 'admin@city.gov',
        action: 'APPROVE',
        target: 'City Council Regular Meeting',
        ipAddress: '192.168.1.100'
      },
      {
        id: 2,
        timestamp: '2025-09-10T14:45:00',
        user: 'jane.doe@city.gov',
        action: 'UPLOAD',
        target: 'Special Budget Review',
        ipAddress: '192.168.1.105'
      }
    ])

    // Table columns
    const pendingColumns = [
      { name: 'title', label: 'Title', field: 'title', align: 'left', sortable: true },
      { name: 'department', label: 'Department', field: 'department', align: 'left' },
      { name: 'submittedBy', label: 'Submitted By', field: 'submittedBy', align: 'left' },
      { name: 'submittedDate', label: 'Submitted', field: 'submittedDate', format: val => formatDate(val) },
      { name: 'meetingDate', label: 'Meeting Date', field: 'meetingDate', format: val => formatDate(val) },
      { name: 'actions', label: 'Actions', field: 'actions', align: 'center' }
    ]

    const publishedColumns = [
      { name: 'title', label: 'Title', field: 'title', align: 'left', sortable: true },
      { name: 'department', label: 'Department', field: 'department', align: 'left' },
      { name: 'publishedDate', label: 'Published', field: 'publishedDate', format: val => formatDate(val) },
      { name: 'meetingDate', label: 'Meeting Date', field: 'meetingDate', format: val => formatDate(val) },
      { name: 'archiveDate', label: 'Archive Date', field: 'archiveDate', format: val => val ? formatDate(val) : 'Manual' },
      { name: 'views', label: 'Views', field: 'views', align: 'center' },
      { name: 'actions', label: 'Actions', field: 'actions', align: 'center' }
    ]

    const userColumns = [
      { name: 'name', label: 'Name', field: 'name', align: 'left', sortable: true },
      { name: 'email', label: 'Email', field: 'email', align: 'left' },
      { name: 'department', label: 'Department', field: 'department', align: 'left' },
      { name: 'role', label: 'Role', field: 'role', align: 'left' },
      { name: 'status', label: 'Status', field: 'active', align: 'center' },
      { name: 'lastLogin', label: 'Last Login', field: 'lastLogin', format: val => formatDate(val) },
      { name: 'actions', label: 'Actions', field: 'actions', align: 'center' }
    ]

    const auditColumns = [
      { name: 'timestamp', label: 'Time', field: 'timestamp', format: val => formatDate(val) },
      { name: 'user', label: 'User', field: 'user', align: 'left' },
      { name: 'action', label: 'Action', field: 'action', align: 'center' },
      { name: 'target', label: 'Target', field: 'target', align: 'left' },
      { name: 'ipAddress', label: 'IP Address', field: 'ipAddress', align: 'left' }
    ]

    const departmentOptions = [
      'City Council',
      'Planning Department',
      'Parks & Recreation',
      'Public Works',
      'Fire Department',
      'Police Department',
      'Finance Department',
      'Human Resources'
    ]

    const roleOptions = ['Staff', 'Admin', 'Super Admin']

    const formatDate = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const getActionColor = (action) => {
      switch (action) {
        case 'APPROVE': return 'green'
        case 'REJECT': return 'red'
        case 'UPLOAD': return 'blue'
        case 'DELETE': return 'red'
        case 'EDIT': return 'orange'
        default: return 'grey'
      }
    }

    const viewDocument = (agenda) => {
      $q.notify({
        message: `Viewing document: ${agenda.title}`,
        position: 'top'
      })
    }

    const approveAgenda = (agenda) => {
      $q.dialog({
        title: 'Approve Agenda',
        message: `Are you sure you want to approve "${agenda.title}"?`,
        cancel: true,
        persistent: true
      }).onOk(() => {
        // Move from pending to published
        const index = pendingAgendas.value.findIndex(a => a.id === agenda.id)
        if (index > -1) {
          pendingAgendas.value.splice(index, 1)
          publishedAgendas.value.unshift({
            ...agenda,
            publishedDate: new Date().toISOString(),
            views: 0
          })
          stats.value.pending--
          stats.value.published++
        }
        
        $q.notify({
          type: 'positive',
          message: 'Agenda approved and published',
          position: 'top'
        })
      })
    }

    const rejectAgenda = (agenda) => {
      $q.dialog({
        title: 'Reject Agenda',
        message: `Are you sure you want to reject "${agenda.title}"?`,
        cancel: true,
        persistent: true
      }).onOk(() => {
        const index = pendingAgendas.value.findIndex(a => a.id === agenda.id)
        if (index > -1) {
          pendingAgendas.value.splice(index, 1)
          stats.value.pending--
        }
        
        $q.notify({
          type: 'positive',
          message: 'Agenda rejected',
          position: 'top'
        })
      })
    }

    const unpublishAgenda = (agenda) => {
      $q.notify({
        message: `Unpublishing: ${agenda.title}`,
        position: 'top'
      })
    }

    const archiveAgenda = (agenda) => {
      $q.notify({
        message: `Archiving: ${agenda.title}`,
        position: 'top'
      })
    }

    const editUser = (user) => {
      $q.notify({
        message: `Editing user: ${user.name}`,
        position: 'top'
      })
    }

    const toggleUserStatus = (user) => {
      user.active = !user.active
      $q.notify({
        type: 'positive',
        message: `User ${user.active ? 'activated' : 'deactivated'}`,
        position: 'top'
      })
    }

    const createUser = () => {
      if (newUser.value.email && newUser.value.name) {
        users.value.push({
          id: users.value.length + 1,
          ...newUser.value,
          active: true,
          lastLogin: null
        })

        newUser.value = {
          email: '',
          name: '',
          department: '',
          role: ''
        }

        $q.notify({
          type: 'positive',
          message: 'User created successfully',
          position: 'top'
        })
      }
    }

    const logout = () => {
      localStorage.removeItem('userInfo')
      router.push('/login')
    }

    onMounted(() => {
      const stored = localStorage.getItem('userInfo')
      if (stored) {
        userInfo.value = JSON.parse(stored)
        if (userInfo.value.role !== 'admin') {
          router.push('/staff')
        }
      } else {
        router.push('/login')
      }
    })

    return {
      userInfo,
      activeTab,
      showAddUserDialog,
      stats,
      newUser,
      pendingAgendas,
      publishedAgendas,
      users,
      auditLog,
      pendingColumns,
      publishedColumns,
      userColumns,
      auditColumns,
      departmentOptions,
      roleOptions,
      formatDate,
      getActionColor,
      viewDocument,
      approveAgenda,
      rejectAgenda,
      unpublishAgenda,
      archiveAgenda,
      editUser,
      toggleUserStatus,
      createUser,
      logout
    }
  }
})
</script>