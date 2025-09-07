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
      <q-card-section class="bg-orange-2">
        <div class="row items-center">
          <q-icon name="warning" color="orange" size="md" class="q-mr-md" />
          <div class="col">
            <div class="text-weight-medium text-grey-8">
              72-Hour Compliance Reminder
            </div>
            <div class="text-caption text-grey-7">
              All meeting agendas must be posted at least 72 hours before the
              meeting time. Current deadline for next submission:
              {{ nextDeadline }}
            </div>
          </div>
          <q-btn
            flat
            color="grey-7"
            icon="close"
            @click="showComplianceAlert = false"
          />
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
                hint="Meeting will be automatically Archived 24hrs after the meeting date/time"
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

              <!-- Set to auto-archive based on meeting date and current date by default -->
              <!-- <div class="row q-gutter-md">
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
              </div> -->

              <q-file
                v-model="agendaForm.document"
                label="Agenda Document (PDF)"
                outlined
                accept=".pdf"
                max-file-size="10485760"
                :rules="[(val) => !!val || 'PDF document is required']"
                lazy-rules
                @added="handleFileAdded"
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
                    :color="
                      getStatusColor(getSubmissionStatus(item.meetingDate))
                    "
                    :label="getSubmissionStatus(item.meetingDate)"
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
                    <!-- TODO: Implement edit feature to updated item details -->
                    <!-- <q-btn
                      flat
                      round
                      icon="edit"
                      size="sm"
                      @click="editSubmission(item)"
                      :disable="item.status === 'Published'"
                    /> -->
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
      // Calculate 72 hours from now
      const deadline = new Date();
      deadline.setHours(deadline.getHours() + 72);
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
      const minDate = new Date(now.getTime() + 72 * 60 * 60 * 1000); // 48 hours from now

      if (meetingDate < minDate) {
        return "Meeting must be at least 72 hours from now";
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

    function getSubmissionStatus(meetingDate) {
      const now = new Date();
      const meeting = new Date(meetingDate);

      const diffMs = meeting - now; // milliseconds until meeting
      const diffHours = diffMs / (1000 * 60 * 60);

      if (diffHours < -24) {
        return "Archived"; // more than 24hrs past meeting
      } else if (diffHours <= 0) {
        return "Archived"; // meeting already started and within last 24hrs
      } else if (diffHours <= 72) {
        return "Published"; // meeting within 72hrs
      } else {
        return "Pending"; // meeting more than 72hrs away
      }
    }

    function getStatusColor(status) {
      switch (status) {
        case "Published":
          return "green";
        case "Pending":
          return "orange";
        case "Archived":
          return "grey";
        default:
          return "blue";
      }
    }

    const handleFileAdded = (file) => {
      // Convert File object to Blob if needed
      agendaForm.value.document = file;
    };

    const submitAgenda = async () => {
      if (!isFormValid.value) return;

      uploadLoading.value = true;
      try {
        console.log(userInfo.value.department);
        // Step 1: POST metadata to Lambda to get pre-signed URL1
        const lambdaResponse = await fetch(
          "https://n53xj7bu2i54ycxd62czizyrpu0pcvxg.lambda-url.us-east-1.on.aws/",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              title: agendaForm.value.title,
              department: userInfo.value.department,
              meetingDate: agendaForm.value.meetingDate,
              archiveDate: agendaForm.value.archiveDate || "none",
            }),
          }
        );

        if (!lambdaResponse.ok) {
          throw new Error(
            `Lambda error: ${lambdaResponse.status} ${lambdaResponse.statusText}`
          );
        }

        const { uploadUrl, publicUrl, fileKey } = await lambdaResponse.json();

        if (!uploadUrl) {
          throw new Error("No pre-signed URL returned from Lambda");
        }

        // Step 2: PUT the PDF directly to S3 using the pre-signed URL
        const file = agendaForm.value.document;
        if (!(file instanceof File)) throw new Error("No file selected");

        const s3Response = await fetch(uploadUrl, {
          method: "PUT",
          body: file,
          // headers: {
          //   "Content-Type": "application/pdf", // must match Lambda pre-signed URL ContentType
          // },
        });

        if (!s3Response.ok) {
          throw new Error(
            `S3 upload failed: ${s3Response.status} ${s3Response.statusText}`
          );
        }

        // Step 3: Add submission to local recentSubmissions list
        const newSubmission = {
          id: Date.now(),
          title: agendaForm.value.title,
          meetingDate: agendaForm.value.meetingDate,
          submittedDate: new Date().toISOString(),
          status: "Pending",
          publicUrl, // store public link for viewing
          fileKey,
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
          message: "Agenda uploaded successfully!",
          position: "top",
        });
      } catch (error) {
        console.error(error);
        $q.notify({
          type: "negative",
          message: `Failed to upload agenda: ${error.message}`,
          position: "top",
        });
      } finally {
        uploadLoading.value = false;
      }
    };

    const fetchRecentSubmissions = async () => {
      try {
        const response = await fetch(
          "https://electronic-bulletin-board.s3.amazonaws.com/?list-type=2&prefix=pdfs/"
        );

        if (!response.ok) {
          throw new Error(`S3 list fetch failed: ${response.status}`);
        }

        const xmlText = await response.text();
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(xmlText, "application/xml");

        const contents = [...xmlDoc.getElementsByTagName("Contents")];
        const submissions = contents
          .map((item) => {
            const key = item.getElementsByTagName("Key")[0].textContent;

            // Skip folder placeholder (like "pdfs/")
            if (key.endsWith("/")) return null;

            const lastModified =
              item.getElementsByTagName("LastModified")[0].textContent;
            const size = item.getElementsByTagName("Size")[0].textContent;

            const publicUrl = `https://electronic-bulletin-board.s3.amazonaws.com/${encodeURIComponent(
              key
            )}`;

            // Strip folder prefix
            const fileName = key.replace("pdfs/", "");

            // Try parsing metadata from filename
            const parts = fileName.split("_");
            let title = "Unknown";
            let department = "Unknown";
            let meetingDate = "Unknown";
            let archiveDate = "Unknown";
            let timestamp = "";

            if (parts.length >= 5) {
              title = decodeURIComponent(parts[0]).replace(/-/g, " ");
              department = decodeURIComponent(parts[1]).replace(/-/g, " ");
              meetingDate = parts[2];
              archiveDate = parts[3];
              timestamp = parts[4].replace(".pdf", "");
            }

            return {
              fileKey: key,
              title,
              department,
              meetingDate,
              archiveDate,
              uploadedAt: new Date(lastModified),
              size: Number(size),
              publicUrl,
            };
          })
          .filter(Boolean); // remove nulls

        submissions.sort((a, b) => b.uploadedAt - a.uploadedAt);

        recentSubmissions.value = submissions;
        console.log(recentSubmissions.value);
      } catch (error) {
        console.error("Error fetching submissions:", error);
        $q.notify({
          type: "negative",
          message: "Failed to load recent submissions",
          position: "top",
        });
      }
    };

    // const submitAgenda = async () => {
    //   uploadLoading.value = true;

    //   try {
    //     // Simulate file upload and processing
    //     await new Promise((resolve) => setTimeout(resolve, 2000));

    //     // In real app: upload to S3, save to DynamoDB, etc.
    //     const newSubmission = {
    //       id: Date.now(),
    //       title: agendaForm.value.title,
    //       meetingDate: agendaForm.value.meetingDate,
    //       submittedDate: new Date().toISOString(),
    //       status: "Pending",
    //       department: userInfo.value?.department,
    //     };

    //     recentSubmissions.value.unshift(newSubmission);

    //     // Reset form
    //     agendaForm.value = {
    //       title: "",
    //       meetingDate: "",
    //       description: "",
    //       document: null,
    //       archiveDate: "",
    //       autoArchive: false,
    //     };

    //     $q.notify({
    //       type: "positive",
    //       message: "Agenda submitted successfully!",
    //       position: "top",
    //     });
    //   } catch (error) {
    //     $q.notify({
    //       type: "negative",
    //       message: "Failed to submit agenda. Please try again.",
    //       position: "top",
    //     });
    //   } finally {
    //     uploadLoading.value = false;
    //   }
    // };
    const viewSubmission = (item) => {
      if (item.publicUrl) {
        window.open(item.publicUrl, "_blank");
      } else {
        $q.notify({
          type: "negative",
          message: "No document available to view",
          position: "top",
        });
      }
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
        fetchRecentSubmissions();
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
      getSubmissionStatus,
      submitAgenda,
      viewSubmission,
      editSubmission,
      logout,
      handleFileAdded,
    };
  },
});
</script>
