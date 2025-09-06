<template>
  <q-page class="q-pa-xs" :class="{ 'display-mode': displayMode }">
    <!-- Header - hidden in display mode -->
    <div v-if="!displayMode" class="text-center q-mb-lg">
      <h3 class="text-h4 q-mb-sm">Public Meeting Agendas</h3>
      <p class="text-grey-7">All upcoming and recent city meeting agendas</p>
    </div>

    <!-- Display Mode Header -->
    <div v-else class="display-mode-header q-mb-lg">
      <h1 class="text-h2 text-center text-white q-mb-none">
        City Meeting Agendas
      </h1>
      <div class="text-center text-grey-3">
        <q-icon name="access_time" class="q-mr-sm" />
        {{
          new Date().toLocaleDateString("en-US", {
            weekday: "long",
            year: "numeric",
            month: "long",
            day: "numeric",
          })
        }}
      </div>
    </div>

    <!-- Search and Filter Bar - hidden in display mode -->
    <!-- <q-card v-if="!displayMode" flat bordered class="q-mb-lg"> -->
    <!-- <q-card-section> -->
    <div
      v-if="!displayMode"
      class="row justify-center items-center q-my-xs q-mx-sm"
    >
      <div class="col-md-2 col-12 q-ma-xs">
        <q-input
          v-model="searchQuery"
          placeholder="Search agendas..."
          outlined
          clearable
        >
          <template v-slot:prepend>
            <q-icon name="search" />
          </template>
        </q-input>
      </div>

      <div class="col-md-2 col-12 q-ma-xs">
        <q-select
          v-model="selectedDepartment"
          :options="departments"
          placeholder="Department"
          outlined
          clearable
        />
      </div>

      <div class="col-md-2 col-12 q-ma-xs">
        <q-input v-model="dateFilter" type="date" outlined placeholder="Date" />
      </div>
    </div>
    <div
      v-if="!displayMode"
      class="row justify-center items-center q-my-xs q-mx-sm"
    >
      <div class="col-md-2 col-12 q-ma-xs">
        <q-btn
          color="primary"
          label="Filter"
          @click="applyFilters"
          class="full-width"
        />
      </div>
    </div>
    <div
      v-if="!displayMode"
      class="row justify-center items-center q-my-xs q-mx-sm"
    >
      <div class="col-md-2 col-12 q-ma-xs flex justify-center items-center">
        <q-toggle
          v-model="showPdfPreviews"
          label="Show PDF Previews"
          color="primary"
        />
      </div>

      <div class="col-md-2 col-12 q-ma-xs flex justify-center items-center">
        <q-btn
          :color="displayMode ? 'negative' : 'positive'"
          :label="displayMode ? 'Exit Display Mode' : 'Display Mode'"
          :icon="displayMode ? 'fullscreen_exit' : 'fullscreen'"
          @click="toggleDisplayMode"
          outline
        />
      </div>

      <div class="col-md-2 col-12 q-ma-xs flex justify-center items-center">
        <ThemeToggle 
          :show-label="true"
          outline
          color="primary"
        />
      </div>
    </div>
    <!-- </q-card-section> -->
    <!-- </q-card> -->

    <!-- Agendas Grid -->
    <div
      class="row justify-center q-gutter-sm"
      :class="{ 'display-mode-grid': displayMode }"
    >
      <div
        v-for="agenda in filteredAgendas"
        :key="agenda.id"
        :class="
          displayMode ? 'col-lg-3 col-md-3' : 'col-lg-3 col-md-3 col-sm-2'
        "
      >
        <q-card
          class="agenda-card"
          :class="{ 'display-mode-card': displayMode }"
        >
          <!-- PDF Preview Section -->
          <div
            v-if="(showPdfPreviews && !displayMode) || displayMode"
            class="pdf-preview-section"
          >
            <PdfPreview
              :pdf-url="agenda.documentUrl"
              :auto-play="displayMode"
              :display-mode="displayMode"
              :cycle-speed="displayMode ? 8000 : 5000"
            />
          </div>

          <!-- Agenda Info Section -->
          <div
            class="agenda-info"
            :class="{ 'display-mode-info': displayMode }"
          >
            <q-card-section class="q-pb-sm">
              <div
                class="text-h6 q-mb-sm"
                :class="{ 'text-h4 text-white': displayMode }"
              >
                {{ agenda.title }}
              </div>
              <div
                class="text-subtitle2 q-mb-sm"
                :class="displayMode ? 'text-grey-3' : 'text-grey-7'"
              >
                <q-icon name="business" class="q-mr-sm" />
                {{ agenda.department }}
              </div>
            </q-card-section>

            <q-separator v-if="!displayMode" />

            <!-- Compact info for display mode, detailed for normal mode -->
            <q-card-section v-if="!displayMode">
              <div class="row items-center justify-between">
                <div class="col">
                  <div class="text-caption text-grey-6">Meeting Date</div>
                  <div class="text-body2">
                    <q-icon name="event" class="q-mr-sm" />
                    {{ formatDate(agenda.meetingDate) }}
                  </div>
                </div>
                <div class="col">
                  <div class="text-caption text-grey-6">Posted</div>
                  <div class="text-body2">
                    <q-icon name="schedule" class="q-mr-sm" />
                    {{ formatDate(agenda.postedDate) }}
                  </div>
                </div>
              </div>
            </q-card-section>

            <q-card-section v-if="!displayMode" class="q-pt-none">
              <div class="text-caption text-grey-6 q-mb-sm">Description</div>
              <div class="text-body2">{{ agenda.description }}</div>
            </q-card-section>

            <!-- Display mode compact info -->
            <div v-else class="display-mode-compact-info">
              <div class="text-body1 text-white q-mb-sm">
                <q-icon name="event" class="q-mr-sm" />
                {{ formatDate(agenda.meetingDate) }}
              </div>
              <div class="text-caption text-grey-3" v-if="agenda.archiveDate">
                <q-icon name="archive" class="q-mr-sm" />
                Archives: {{ formatDate(agenda.archiveDate) }}
              </div>
            </div>

            <!-- Actions - hidden in display mode -->
            <q-card-actions v-if="!displayMode" align="right">
              <q-btn
                flat
                color="primary"
                label="View Agenda"
                @click="viewAgenda(agenda)"
                icon="picture_as_pdf"
              />
            </q-card-actions>

            <!-- Status Badge -->
            <q-badge
              :color="getStatusColor(agenda.status)"
              class="absolute-top-right q-ma-sm"
              :class="{ 'status-badge-large': displayMode }"
            >
              {{ agenda.status }}
            </q-badge>
          </div>
        </q-card>
      </div>
    </div>

    <!-- Empty State -->
    <div v-if="filteredAgendas.length === 0" class="text-center q-mt-xl">
      <q-icon name="description" size="100px" color="grey-5" />
      <div class="text-h6 text-grey-6 q-mt-md">No agendas found</div>
      <div class="text-body2 text-grey-6">
        Try adjusting your search criteria
      </div>
    </div>

    <!-- Auto-refresh indicator for kiosk mode -->
    <div class="fixed-bottom-right q-ma-md">
      <q-chip
        v-if="kioskMode"
        color="green"
        text-color="white"
        icon="refresh"
        class="animate-pulse"
      >
        Auto-refresh: {{ refreshCountdown }}s
      </q-chip>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref, computed, onMounted, onUnmounted } from "vue";
import PdfPreview from "src/components/PdfPreview.vue";
import ThemeToggle from "src/components/ThemeToggle.vue";

export default defineComponent({
  name: "BulletinBoard",

  components: {
    PdfPreview,
    ThemeToggle,
  },

  setup() {
    const searchQuery = ref("");
    const selectedDepartment = ref(null);
    const dateFilter = ref("");
    const kioskMode = ref(false);
    const refreshCountdown = ref(30);
    const refreshInterval = ref(null);
    const showPdfPreviews = ref(false);
    const displayMode = ref(false);

    // Sample data using actual PDF files from src/agendas/
    const agendas = ref([
      {
        id: 1,
        title: "City Council Meeting - September 9, 2025",
        department: "City Council",
        meetingDate: "2025-09-09T19:00:00",
        postedDate: "2025-09-07T10:00:00",
        archiveDate: "2025-09-11T19:00:00",
        autoArchive: true,
        description:
          "Regular city council meeting to discuss municipal affairs, budget items, and community development projects.",
        status: "Published",
        documentUrl: "/docs/Agenda_2025_9_9_Meeting(753).pdf",
      },
      {
        id: 2,
        title: "Planning Commission Meeting - September 3, 2025",
        department: "Planning Department",
        meetingDate: "2025-09-03T18:30:00",
        postedDate: "2025-09-01T14:30:00",
        archiveDate: "2025-09-05T18:30:00",
        autoArchive: true,
        description:
          "Planning commission review of development proposals, zoning changes, and permit applications.",
        status: "Archived",
        documentUrl: "/docs/Agenda_2025_9_3_Meeting(752).pdf",
      },
      {
        id: 3,
        title: "Parks & Recreation Board - August 26, 2025",
        department: "Parks & Recreation",
        meetingDate: "2025-08-26T17:00:00",
        postedDate: "2025-08-24T09:00:00",
        archiveDate: "2025-08-28T17:00:00",
        autoArchive: true,
        description:
          "Discussion of park improvements, recreational programs, and facility maintenance.",
        status: "Archived",
        documentUrl: "/docs/Agenda_2025_8_26_Meeting(751).pdf",
      },
      {
        id: 4,
        title: "Public Works Committee - August 19, 2025",
        department: "Public Works",
        meetingDate: "2025-08-19T16:00:00",
        postedDate: "2025-08-17T08:00:00",
        archiveDate: "2025-08-21T16:00:00",
        autoArchive: true,
        description:
          "Infrastructure projects, road maintenance, and utility updates.",
        status: "Archived",
        documentUrl: "/docs/Agenda_2025_8_19_Meeting(750).pdf",
      },
      {
        id: 5,
        title: "Finance Committee Meeting - August 12, 2025",
        department: "Finance Department",
        meetingDate: "2025-08-12T14:00:00",
        postedDate: "2025-08-10T11:00:00",
        archiveDate: "2025-08-14T14:00:00",
        autoArchive: true,
        description: "Budget review, financial reports, and audit discussions.",
        status: "Archived",
        documentUrl: "/docs/Agenda_2025_8_12_Meeting(749).pdf",
      },
      {
        id: 6,
        title: "City Council Meeting - July 29, 2025",
        department: "City Council",
        meetingDate: "2025-07-29T19:00:00",
        postedDate: "2025-07-27T10:00:00",
        archiveDate: "2025-07-31T19:00:00",
        autoArchive: true,
        description:
          "Monthly council meeting covering ordinances, resolutions, and public hearings.",
        status: "Archived",
        documentUrl: "/docs/Agenda_2025_7_29_Meeting(747).pdf",
      },
      {
        id: 7,
        title: "Special Session - July 22, 2025",
        department: "City Council",
        meetingDate: "2025-07-22T20:00:00",
        postedDate: "2025-07-20T16:00:00",
        archiveDate: "2025-07-24T20:00:00",
        autoArchive: true,
        description:
          "Special session to address urgent municipal matters and emergency ordinances.",
        status: "Archived",
        documentUrl: "/docs/Agenda_2025_7_22_Meeting(745).pdf",
      },
    ]);

    const departments = [
      "City Council",
      "Planning Department",
      "Parks & Recreation",
      "Public Works",
      "Finance Department",
      "Fire Department",
      "Police Department",
    ];

    const filteredAgendas = computed(() => {
      let filtered = agendas.value;

      if (searchQuery.value) {
        filtered = filtered.filter(
          (agenda) =>
            agenda.title
              .toLowerCase()
              .includes(searchQuery.value.toLowerCase()) ||
            agenda.description
              .toLowerCase()
              .includes(searchQuery.value.toLowerCase())
        );
      }

      if (selectedDepartment.value) {
        filtered = filtered.filter(
          (agenda) => agenda.department === selectedDepartment.value
        );
      }

      if (dateFilter.value) {
        filtered = filtered.filter((agenda) => {
          const meetingDate = new Date(agenda.meetingDate)
            .toISOString()
            .split("T")[0];
          return meetingDate === dateFilter.value;
        });
      }

      // Sort by meeting date, upcoming first
      return filtered.sort(
        (a, b) => new Date(a.meetingDate) - new Date(b.meetingDate)
      );
    });

    const formatDate = (dateString) => {
      const date = new Date(dateString);
      return date.toLocaleDateString("en-US", {
        weekday: "short",
        year: "numeric",
        month: "short",
        day: "numeric",
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
        case "Archived":
          return "grey";
        default:
          return "blue";
      }
    };

    const viewAgenda = (agenda) => {
      // In a real app, this would open the PDF or navigate to document viewer
      window.open(agenda.documentUrl, "_blank");
    };

    const toggleDisplayMode = () => {
      displayMode.value = !displayMode.value;

      if (displayMode.value) {
        // Enable PDF previews automatically in display mode
        showPdfPreviews.value = true;
        // Hide cursor and make fullscreen-like
        document.body.style.cursor = "none";
        document.body.style.overflow = "hidden";
      } else {
        // Restore normal cursor and scrolling
        document.body.style.cursor = "auto";
        document.body.style.overflow = "auto";
      }
    };

    const applyFilters = () => {
      // Filters are applied reactively through computed property
      // This function could trigger analytics or other side effects
    };

    const checkAutoArchive = () => {
      const now = new Date();
      agendas.value.forEach((agenda) => {
        if (
          agenda.autoArchive &&
          agenda.archiveDate &&
          new Date(agenda.archiveDate) <= now
        ) {
          if (agenda.status !== "Archived") {
            agenda.status = "Archived";
            console.log(`Auto-archived: ${agenda.title}`);
          }
        }
      });
    };

    const startKioskMode = () => {
      kioskMode.value = true;
      refreshInterval.value = setInterval(() => {
        refreshCountdown.value--;
        if (refreshCountdown.value <= 0) {
          // Refresh data
          refreshCountdown.value = 30;
          // In real app: fetchAgendas()
        }
      }, 1000);
    };

    // Check if kiosk mode or display mode should be enabled (could be query param)
    onMounted(() => {
      const urlParams = new URLSearchParams(window.location.search);
      if (urlParams.get("kiosk") === "true") {
        startKioskMode();
      }
      if (urlParams.get("display") === "true") {
        toggleDisplayMode();
      }

      // Check for auto-archive every minute
      setInterval(checkAutoArchive, 60000);
      checkAutoArchive(); // Initial check
    });

    onUnmounted(() => {
      if (refreshInterval.value) {
        clearInterval(refreshInterval.value);
      }

      // Restore body styles
      document.body.style.cursor = "auto";
      document.body.style.overflow = "auto";
    });

    return {
      searchQuery,
      selectedDepartment,
      dateFilter,
      departments,
      filteredAgendas,
      kioskMode,
      refreshCountdown,
      showPdfPreviews,
      displayMode,
      formatDate,
      getStatusColor,
      viewAgenda,
      applyFilters,
      toggleDisplayMode,
    };
  },
});
</script>

<style scoped>
.agenda-card {
  height: 100%;
  transition: transform 0.2s;
}

.agenda-card:hover {
  transform: translateY(-2px);
}

.animate-pulse {
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

/* Display Mode Styles */
.display-mode {
  background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
  min-height: 100vh;
}

.display-mode-header {
  padding: 2rem 0;
  text-align: center;
  background: rgba(0, 0, 0, 0.2);
  margin: -1rem -1rem 2rem -1rem;
  color: white;
}

.display-mode-grid {
  gap: 2rem !important;
}

.display-mode-card {
  background: var(--bg-secondary);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 32px var(--shadow);
  border: 1px solid var(--border-color);
  min-height: 600px;
  display: flex;
  flex-direction: column;
}

.pdf-preview-section {
  flex: 1;
  min-height: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-tertiary);
  border-radius: 8px;
  margin: 1rem;
}

.agenda-info {
  position: relative;
}

.display-mode-info {
  background: linear-gradient(135deg, #1976d2 0%, #42a5f5 100%);
  color: white;
  padding: 1rem;
  border-radius: 0 0 16px 16px;
}

.display-mode-compact-info {
  padding: 0 1rem 1rem 1rem;
}

.status-badge-large {
  font-size: 0.9rem;
  padding: 0.5rem 1rem;
}

/* Responsive adjustments for display mode */
@media (max-width: 1200px) {
  .display-mode-card {
    min-height: 500px;
  }

  .pdf-preview-section {
    min-height: 300px;
  }
}

@media (max-width: 768px) {
  .display-mode-card {
    min-height: 400px;
  }

  .pdf-preview-section {
    min-height: 250px;
    margin: 0.5rem;
  }

  .display-mode-header h1 {
    font-size: 2rem;
  }
}

/* Hide scrollbars in display mode */
.display-mode::-webkit-scrollbar {
  display: none;
}

.display-mode {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>
