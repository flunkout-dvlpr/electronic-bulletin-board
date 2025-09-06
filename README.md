# 📰 Digital Bulletin Board

A modern web-based solution to replace physical city bulletin boards for publishing public meeting agendas. Built with Quasar Framework (Vue.js) and designed for AWS deployment.

## 🚀 Features

### Public Features
- **Digital Board Display**: View all upcoming and recent meeting agendas
- **PDF Preview**: Display actual PDF content with automatic page cycling
- **Display Mode**: Full-screen mode optimized for large public displays
- **Search & Filter**: Find agendas by department, date, or keywords
- **Responsive Design**: Works on desktop, tablet, and mobile devices
- **Auto-Archive**: Automatically archive agendas based on configured dates

### Staff Features
- **Secure Login**: Department-specific authentication
- **Agenda Upload**: Easy PDF document upload with metadata
- **Archive Configuration**: Set manual or automatic archive dates
- **Compliance Checking**: Automatic 48-hour rule validation
- **Submission Tracking**: View status of submitted agendas

### Admin Features
- **Review Dashboard**: Approve or reject pending submissions
- **User Management**: Add and manage staff accounts
- **Audit Trail**: Complete logging of all system actions
- **Content Moderation**: Publish, unpublish, or archive agendas

## 🛠️ Tech Stack

- **Frontend**: Quasar Framework (Vue.js 3)
- **State Management**: Pinia
- **Routing**: Vue Router
- **UI Components**: Material Design
- **Build Tool**: Vite
- **Backend (Planned)**: AWS (Cognito, S3, DynamoDB, Lambda, API Gateway)

## 🏗️ Project Structure

```
src/
├── components/          # Reusable Vue components
├── layouts/            # Layout components
├── pages/              # Page components
│   ├── IndexPage.vue   # Landing page
│   ├── BulletinBoard.vue # Public agenda display
│   ├── LoginPage.vue   # Staff authentication
│   ├── StaffDashboard.vue # Staff upload interface
│   └── AdminDashboard.vue # Admin management panel
├── router/             # Vue Router configuration
├── stores/             # Pinia stores (state management)
├── css/                # Global styles
└── boot/               # Quasar boot files
```

## 🚦 Getting Started

### Prerequisites
- Node.js (v18 or higher)
- npm or yarn

### Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start development server:**
   ```bash
   npm run dev
   ```

3. **Build for production:**
   ```bash
   npm run build
   ```

### Sample Data

The application now uses actual PDF files from real city meeting agendas:
- 7 actual agenda PDFs from July-September 2025
- Real PDF rendering with PDF.js library
- Multi-page document support with auto-cycling
- Proper archive dates and department assignments

### Mock Authentication

For development, use these test accounts:

**Staff Account:**
- Email: staff@city.gov
- Password: password
- Department: Any department

**Admin Account:**
- Email: admin@city.gov
- Password: password
- Department: Any department

## 📋 Core Functionality

### 48-Hour Compliance Rule
The system enforces the legal requirement that all meeting agendas must be posted at least 48 hours before the meeting time.

### PDF Display & Management
- **PDF Preview**: Display actual PDF content with page cycling
- **Display Mode**: Optimized for large screens and kiosks
- **Auto-Archive**: Configure automatic or manual archiving
- **Page Navigation**: Manual controls and automatic cycling

### Role-Based Access
- **Public**: View published agendas with PDF previews
- **Staff**: Upload and manage department agendas
- **Admin**: Oversee all submissions and user management

### Document Management
- PDF upload support with preview generation
- Metadata tracking (title, description, meeting/archive dates)
- Automatic timestamp recording
- Immutable audit trail

### Display Modes
- **Normal Mode**: Full interface with search, filters, and controls
- **Display Mode**: Simplified interface for public kiosks and large displays
- **PDF Toggle**: Option to enable/disable PDF previews
- **Auto-Cycling**: Automatic page turning for multi-page PDFs

## 🔧 Configuration

### Environment Variables
Create a `.env` file for local development:

```env
# API Configuration
API_URL=http://localhost:3001/api

# AWS Configuration (for production)
AWS_REGION=us-east-1
AWS_USER_POOL_ID=your-cognito-pool-id
AWS_USER_POOL_CLIENT_ID=your-client-id
```

### URL Parameters

The bulletin board supports several URL parameters for different display modes:

- **Display Mode**: `?display=true` - Enables full-screen display mode optimized for large screens
- **Kiosk Mode**: `?kiosk=true` - Enables traditional kiosk mode with auto-refresh
- **Combined**: `?display=true&kiosk=true` - Both display and kiosk modes

#### Examples:
```
# Normal public board
http://localhost:9000/#/board

# Display mode for large screens
http://localhost:9000/#/board?display=true

# Kiosk mode with auto-refresh
http://localhost:9000/#/board?kiosk=true

# Full kiosk display mode
http://localhost:9000/#/board?display=true&kiosk=true
```

## 🚀 Deployment

This application is designed for AWS deployment using:

- **S3 + CloudFront**: Static hosting
- **AWS Cognito**: User authentication
- **API Gateway + Lambda**: Backend API
- **DynamoDB**: Database
- **S3**: Document storage

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📜 Legal Compliance

This system is designed to help municipalities comply with open meeting laws, including:

- 48-hour advance notice requirements
- Public accessibility of meeting agendas
- Permanent record keeping
- Audit trail maintenance

## 📞 Support

For technical support or feature requests, please contact the development team or create an issue in the project repository.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.