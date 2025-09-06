<template>
  <q-page class="q-pa-md">
    <div class="row justify-center items-center q-mb-lg">
      <div class="col">
        <h3 class="text-h4 q-my-none">Staff Dashboard</h3>
        <div class="text-grey-7">
          Welcome back, {{ userInfo?.email }} | {{ userInfo?.department }}
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

    <!-- Compliance Alert -->
    <q-card class="q-my-lg" v-if="showComplianceAlert">
      <q-card-section class="bg-orange-1">
        <div class="row items-center">
          <q-icon name="warning" color="orange" size="md" class="q-mr-md" />
          <div class="col">
            <div class="text-weight-medium">48-Hour Compliance Reminder</div>
            <div class="text-caption">
              All meeting agendas must be posted at least 48 hours before the
              meeting time. Current deadline for next submission:
              {{ nextDeadline }}
            </div>
          </div>
          <q-btn flat icon="close" @click="showComplianceAlert = false" />
        </div>
      </q-card-section>
    </q-card>

    <div class="row justify-center q-gutter-lg">
      <!-- Upload Form -->
      <div class="col-md-5 col-sm-12">
        <q-card>
          <q-card-section>
            <div class="text-h6 q-mb-md">
              <q-icon name="upload" class="q-mr-sm" />
              Upload New Agenda
            </div>

            <q-form @submit="submitAgenda" class="q-gutter-md">
              <q-input
                v-model="agendaForm.title"
                label="Meeting Title"
                outlined
                :rules="[(val) => !!val || 'Title is required']"
                lazy-rules
              />

              <q-input
                v-model="agendaForm.meetingDate"
                type="datetime-local"
                label="Meeting Date & Time"
                outlined
                :rules="[
                  (val) => !!val || 'Meeting date is required',
                  validateMeetingDate,
                ]"
                lazy-rules
              />

              <q-input
                v-model="agendaForm.description"
                type="textarea"
                label="Meeting Description"
                outlined
                rows="3"
                :rules="[(val) => !!val || 'Description is required']"
                lazy-rules
              />

              <div class="row q-gutter-md">
                <div class="col">
                  <q-input
                    v-model="agendaForm.archiveDate"
                    type="datetime-local"
                    label="Archive Date (Optional)"
                    outlined
                    hint="When should this agenda be automatically archived?"
                  />
                </div>
                <div class="col-auto flex items-center">
                  <q-toggle
                    v-model="agendaForm.autoArchive"
                    label="Auto Archive"
                    color="primary"
                  />
                </div>
              </div>

              <q-file
                v-model="agendaForm.document"
                label="Agenda Document (PDF)"
                outlined
                accept=".pdf"
                max-file-size="10485760"
                :rules="[(val) => !!val || 'PDF document is required']"
                lazy-rules
              >
                <template v-slot:prepend>
                  <q-icon name="attach_file" />
                </template>
              </q-file>

              <div class="q-mt-lg">
                <q-btn
                  type="submit"
                  color="primary"
                  label="Submit Agenda"
                  :loading="uploadLoading"
                  :disable="!isFormValid"
                  class="full-width"
                />
              </div>
            </q-form>
          </q-card-section>
        </q-card>
      </div>

      <!-- Recent Uploads -->
      <div class="col-md-5 col-sm-12">
        <q-card>
          <q-card-section>
            <div class="text-h6 q-mb-md">
              <q-icon name="history" class="q-mr-sm" />
              Recent Submissions
            </div>

            <q-list separator>
              <q-item
                v-for="item in recentSubmissions"
                :key="item.id"
                class="q-pa-md"
              >
                <q-item-section>
                  <q-item-label class="text-weight-medium">
                    {{ item.title }}
                  </q-item-label>
                  <q-item-label caption>
                    Meeting: {{ formatDate(item.meetingDate) }}
                  </q-item-label>
                  <q-item-label caption>
                    Submitted: {{ formatDate(item.submittedDate) }}
                  </q-item-label>
                </q-item-section>

                <q-item-section side>
                  <q-badge
                    :color="getStatusColor(item.status)"
                    :label="item.status"
                  />
                </q-item-section>

                <q-item-section side>
                  <div class="q-gutter-xs">
                    <q-btn
                      flat
                      round
                      icon="visibility"
                      size="sm"
                      @click="viewSubmission(item)"
                    />
                    <q-btn
                      flat
                      round
                      icon="edit"
                      size="sm"
                      @click="editSubmission(item)"
                      :disable="item.status === 'Published'"
                    />
                  </div>
                </q-item-section>
              </q-item>

              <q-item v-if="recentSubmissions.length === 0">
                <q-item-section class="text-center">
                  <div class="text-grey-6">No submissions yet</div>
                </q-item-section>
              </q-item>
            </q-list>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { useQuasar } from "quasar";

export default defineComponent({
  name: "StaffDashboard",

  setup() {
    const $q = useQuasar();
    const router = useRouter();

    const userInfo = ref(null);
    const uploadLoading = ref(false);
    const showComplianceAlert = ref(true);

    const agendaForm = ref({
      title: "",
      meetingDate: "",
      description: "",
      document: null,
      archiveDate: "",
      autoArchive: false,
    });

    // Mock recent submissions
    const recentSubmissions = ref([
      {
        id: 1,
        title: "Parks Board Monthly Meeting",
        meetingDate: "2025-09-15T17:00:00",
        submittedDate: "2025-09-09T09:00:00",
        status: "Published",
      },
      {
        id: 2,
        title: "Special Budget Review",
        meetingDate: "2025-09-20T19:00:00",
        submittedDate: "2025-09-10T14:30:00",
        status: "Pending",
      },
    ]);

    const isFormValid = computed(() => {
      const basicValid =
        agendaForm.value.title &&
        agendaForm.value.meetingDate &&
        agendaForm.value.description &&
        agendaForm.value.document;

      // If auto-archive is enabled, archive date is required
      if (agendaForm.value.autoArchive && !agendaForm.value.archiveDate) {
        return false;
      }

      return basicValid;
    });

    const nextDeadline = computed(() => {
      // Calculate 48 hours from now
      const deadline = new Date();
      deadline.setHours(deadline.getHours() + 48);
      return deadline.toLocaleDateString("en-US", {
        weekday: "short",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      });
    });

    const validateMeetingDate = (val) => {
      if (!val) return "Meeting date is required";

      const meetingDate = new Date(val);
      const now = new Date();
      const minDate = new Date(now.getTime() + 48 * 60 * 60 * 1000); // 48 hours from now

      if (meetingDate < minDate) {
        return "Meeting must be at least 48 hours from now";
      }
      return true;
    };

    const formatDate = (dateString) => {
      const date = new Date(dateString);
      return date.toLocaleDateString("en-US", {
        month: "short",
        day: "numeric",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      });
    };

    const getStatusColor = (status) => {
      switch (status) {
        case "Published":
          return "green";
        case "Pending":
          return "orange";
        case "Draft":
          return "blue";
        case "Rejected":
          return "red";
        default:
          return "grey";
      }
    };

    const submitAgenda = async () => {
      uploadLoading.value = true;

      try {
        // Simulate file upload and processing
        await new Promise((resolve) => setTimeout(resolve, 2000));

        // In real app: upload to S3, save to DynamoDB, etc.
        const newSubmission = {
          id: Date.now(),
          title: agendaForm.value.title,
          meetingDate: agendaForm.value.meetingDate,
          submittedDate: new Date().toISOString(),
          status: "Pending",
          department: userInfo.value?.department,
        };

        recentSubmissions.value.unshift(newSubmission);

        // Reset form
        agendaForm.value = {
          title: "",
          meetingDate: "",
          description: "",
          document: null,
          archiveDate: "",
          autoArchive: false,
        };

        $q.notify({
          type: "positive",
          message: "Agenda submitted successfully!",
          position: "top",
        });
      } catch (error) {
        $q.notify({
          type: "negative",
          message: "Failed to submit agenda. Please try again.",
          position: "top",
        });
      } finally {
        uploadLoading.value = false;
      }
    };

    const viewSubmission = (item) => {
      // In real app: open document viewer or detail modal
      $q.notify({
        message: `Viewing: ${item.title}`,
        position: "top",
      });
    };

    const editSubmission = (item) => {
      // In real app: populate form with item data
      $q.notify({
        message: `Editing: ${item.title}`,
        position: "top",
      });
    };

    const logout = () => {
      localStorage.removeItem("userInfo");
      router.push("/login");
    };

    onMounted(() => {
      const stored = localStorage.getItem("userInfo");
      if (stored) {
        userInfo.value = JSON.parse(stored);
      } else {
        router.push("/login");
      }
    });

    return {
      userInfo,
      agendaForm,
      uploadLoading,
      showComplianceAlert,
      recentSubmissions,
      isFormValid,
      nextDeadline,
      validateMeetingDate,
      formatDate,
      getStatusColor,
      submitAgenda,
      viewSubmission,
      editSubmission,
      logout,
    };
  },
});
</script>
