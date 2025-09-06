<template>
  <div class="pdf-preview-container" :class="{ 'display-mode': displayMode }">
    <div v-if="loading" class="flex flex-center q-pa-md">
      <q-spinner size="40px" />
      <span class="q-ml-sm">Loading PDF...</span>
    </div>
    
    <div v-else-if="error" class="flex flex-center q-pa-md text-negative">
      <q-icon name="error" size="24px" class="q-mr-sm" />
      <div>
        <div>Failed to load PDF</div>
        <div class="text-caption">{{ errorMessage }}</div>
      </div>
    </div>
    
    <div v-else-if="pageImages.length > 0" class="pdf-slideshow">
      <div class="pdf-canvas-container flex flex-center">
        <img 
          :src="pageImages[pageNum - 1]" 
          :alt="`Page ${pageNum}`"
          class="pdf-canvas shadow-md rounded"
          @error="onImageError"
        />
      </div>

      <!-- Page Controls (hidden in display mode) -->
      <div v-if="!displayMode" class="pdf-controls q-mt-md">
        <q-btn
          dense
          round
          icon="chevron_left"
          @click="prevPage"
          :disable="pageNum <= 1"
          color="primary"
        />
        <span class="page-indicator q-mx-md">
          Page {{ pageNum }} / {{ numPages }}
        </span>
        <q-btn
          dense
          round
          icon="chevron_right"
          @click="nextPage"
          :disable="pageNum >= numPages"
          color="primary"
        />
      </div>
      
      <!-- Auto-cycle indicator for display mode -->
      <div v-if="displayMode" class="cycle-indicator">
        <q-linear-progress 
          :value="cycleProgress" 
          color="primary" 
          size="2px"
        />
        <div class="text-caption text-center q-mt-xs">
          Page {{ pageNum }} of {{ numPages }}
        </div>
      </div>
    </div>
    
    <div v-else class="flex flex-center q-pa-md text-grey-6">
      <div class="text-center">
        <q-icon name="picture_as_pdf" size="40px" color="primary" class="q-mb-sm" />
        <div class="text-body1 q-mb-sm">PDF Document</div>
        <q-btn 
          color="primary" 
          label="Open PDF" 
          icon="open_in_new"
          @click="openPdfExternal"
          outline
        />
      </div>
    </div>
  </div>
</template>

<script>
import { defineComponent, ref, onMounted, onUnmounted, watch } from 'vue'
import * as pdfjsLib from 'pdfjs-dist'

// Set up PDF.js worker - use the new worker format
pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js'

export default defineComponent({
  name: 'PdfPreview',
  
  props: {
    pdfUrl: {
      type: String,
      required: true
    },
    autoPlay: {
      type: Boolean,
      default: false
    },
    displayMode: {
      type: Boolean,
      default: false
    },
    cycleSpeed: {
      type: Number,
      default: 5000
    }
  },
  
  setup(props) {
    const loading = ref(true)
    const error = ref(false)
    const errorMessage = ref('')
    const pageImages = ref([])
    const pageNum = ref(1)
    const numPages = ref(0)
    const timer = ref(null)
    const cycleProgress = ref(0)
    const progressInterval = ref(null)
    
    const loadPdfAsImages = async () => {
      loading.value = true
      error.value = false
      errorMessage.value = ''
      pageImages.value = []
      pageNum.value = 1
      
      try {
        console.log('Loading PDF for image conversion:', props.pdfUrl)
        
        const loadingTask = pdfjsLib.getDocument({
          url: props.pdfUrl,
          disableAutoFetch: false,
          disableStream: false
        })
        
        const pdfDoc = await loadingTask.promise
        console.log(`✅ PDF loaded: ${pdfDoc.numPages} pages`)
        
        // Convert each page to image
        const images = []
        for (let pageNum = 1; pageNum <= pdfDoc.numPages; pageNum++) {
          const pageImage = await renderPageToImage(pdfDoc, pageNum)
          images.push(pageImage)
        }
        
        pageImages.value = images
        numPages.value = images.length
        loading.value = false
        
        console.log(`✅ Converted ${images.length} PDF pages to images`)
        
        // Start auto-cycling if enabled
        if ((props.autoPlay || props.displayMode) && images.length > 1) {
          startAutoCycle()
        }
        
      } catch (err) {
        console.error('❌ Failed to load PDF:', err)
        error.value = true
        errorMessage.value = err.message || 'Failed to load PDF'
        loading.value = false
      }
    }
    
    const renderPageToImage = async (pdfDoc, pageNum) => {
      const page = await pdfDoc.getPage(pageNum)
      
      // Set scale for good quality but reasonable file size
      const scale = 2.0
      const viewport = page.getViewport({ scale })
      
      // Create canvas
      const canvas = document.createElement('canvas')
      const context = canvas.getContext('2d')
      
      canvas.width = viewport.width
      canvas.height = viewport.height
      
      // Render page to canvas
      const renderContext = {
        canvasContext: context,
        viewport: viewport
      }
      
      await page.render(renderContext).promise
      
      // Convert canvas to data URL (image)
      return canvas.toDataURL('image/png', 0.9)
    }
    
    const startAutoCycle = () => {
      if (numPages.value <= 1) return
      
      stopAutoCycle()
      
      let progress = 0
      const progressStep = 100 / (props.cycleSpeed / 100)
      
      progressInterval.value = setInterval(() => {
        progress += progressStep
        cycleProgress.value = progress / 100
        
        if (progress >= 100) {
          progress = 0
          cycleProgress.value = 0
          nextPage()
        }
      }, 100)
    }
    
    const stopAutoCycle = () => {
      if (timer.value) {
        clearInterval(timer.value)
        timer.value = null
      }
      if (progressInterval.value) {
        clearInterval(progressInterval.value)
        progressInterval.value = null
      }
      cycleProgress.value = 0
    }
    
    const nextPage = () => {
      if (pageNum.value >= numPages.value) {
        pageNum.value = 1
      } else {
        pageNum.value++
      }
    }
    
    const prevPage = () => {
      if (pageNum.value <= 1) {
        pageNum.value = numPages.value
      } else {
        pageNum.value--
      }
    }
    
    const onImageError = () => {
      console.error('❌ Failed to load page image')
    }
    
    const openPdfExternal = () => {
      if (props.pdfUrl) {
        window.open(props.pdfUrl, '_blank')
      }
    }
    
    // Watch for changes in autoPlay or displayMode
    watch([() => props.autoPlay, () => props.displayMode], () => {
      if (props.autoPlay || props.displayMode) {
        startAutoCycle()
      } else {
        stopAutoCycle()
      }
    })
    
    // Watch for PDF URL changes
    watch(() => props.pdfUrl, () => {
      if (props.pdfUrl) {
        pageNum.value = 1
        loadPdfAsImages()
      }
    })
    
    onMounted(() => {
      if (props.pdfUrl) {
        loadPdfAsImages()
      }
    })
    
    onUnmounted(() => {
      stopAutoCycle()
    })
    
    return {
      loading,
      error,
      errorMessage,
      pageImages,
      pageNum,
      numPages,
      cycleProgress,
      nextPage,
      prevPage,
      openPdfExternal
    }
  }
})
</script>

<style scoped>
.pdf-preview-container {
  width: 100%;
  height: 100%;
  position: relative;
}

.pdf-slideshow {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.pdf-canvas-container {
  flex: 1;
  min-height: 400px;
}

.pdf-canvas {
  max-width: 100%;
  max-height: 70vh;
  border: 1px solid var(--border-color);
  border-radius: 4px;
  box-shadow: 0 2px 8px var(--shadow);
}

.pdf-controls {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 8px;
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: 20px;
  margin: 8px auto;
  width: fit-content;
}

.page-indicator {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-secondary);
  min-width: 80px;
  text-align: center;
}

.cycle-indicator {
  padding: 8px;
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: 4px;
  margin-top: 8px;
}

/* Display mode styles */
.display-mode .pdf-canvas {
  max-height: 80vh;
}

.display-mode .cycle-indicator {
  position: fixed;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  min-width: 200px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1000;
}

@media (max-width: 768px) {
  .pdf-canvas {
    max-height: 400px;
  }
  
  .display-mode .pdf-canvas {
    max-height: 60vh;
  }
}
</style>