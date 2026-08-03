# HomeHub - Outstanding Tasks & Roadmap (TODO.md)

This document tracks completed features and pending tasks for the **HomeHub** real estate app (Flutter frontend + Go backend).

---

## 🟢 Completed So Far ([x])

### Frontend (Flutter)
- [x] **Core Architecture**: `MultiProvider` state management (`AppThemeProvider`, `PropertyProvider`, `BookingProvider`, `UserProvider`, `ChatProvider`).
- [x] **Design System**: Light & Dark mode themes (`AppTheme`), custom glassmorphism (`GlassContainer`), badge chips, and custom icons.
- [x] **Authentication Flow**: Login, Register, Onboarding, and Splash screens with strict navigation auth guards.
- [x] **Property Search & Filtering**: Multi-criteria property filter drawer (city, LGA, price range, property type, bedrooms) with list and map views.
- [x] **Property & City Views**: Detailed property listing screen with image carousels, landlord info, amenity badges, and city stats screen.
- [x] **User Profile Management**: Edit profile screen, photo avatar selector (`image_picker`), profile completeness progress bar, password updates, and email OTP verification modal.
- [x] **Inspection & Booking UI**: Inspection modal for scheduling property viewings and Bookings tab screen.
- [x] **e-Sign & Escrow UI Modal**: Step-by-step modal for signing digital tenancy agreements and reviewing escrow terms.
- [x] **Local Fallbacks**: Integration with live API endpoints with rich local mock data fallback for offline capability.

### Backend (Go / Fiber API)
- [x] **JWT Authentication**: Login, Register, Logout, Token Refresh, and Auth middleware.
- [x] **User Management**: Public/protected user profile routes, avatar upload, and account deactivation.
- [x] **Listings API**: Public search & filtering by location/type, location stats, public stats, landlord stats, and image upload endpoints.
- [x] **Chat API & WebSockets**: Conversation routes, message retrieval, mark as read, and Fiber WebSocket hub (`/api/messages/ws`).
- [x] **Bookmarks & Admin**: Toggle bookmarks, admin stats, verify listings, and toggle featured property flags.

---

## 🟡 High Priority TODOs ([ ])

### 1. Frontend Integration & Enhancements (Flutter)
- [ ] **Live API Integration for Landlord Property Creation**:
  - Connect [`AddPropertyModal`](file:///home/chrisdev/Desktop/homehub-app/lib/widgets/add_property_modal.dart) directly to `POST /api/listings` and `POST /api/listings/upload-images` instead of local state mutation only.
- [ ] **Live API Integration for Bookings**:
  - Connect [`BookingProvider`](file:///home/chrisdev/Desktop/homehub-app/lib/providers/booking_provider.dart) to real backend REST endpoints for creating and updating inspection bookings.
- [ ] **WebSocket Client for Chat**:
  - Wire up a live WebSocket listener in [`ChatProvider`](file:///home/chrisdev/Desktop/homehub-app/lib/providers/chat_provider.dart) to receive instant push messages without pulling manually.
- [ ] **Google Sign-In Integration**:
  - Integrate native Google Sign-In SDK on Android & iOS to send idTokens to backend `POST /api/auth/google`.
- [ ] **Environment Configuration**:
  - Replace hardcoded `baseUrl` with `.env` / `String.fromEnvironment` configuration for switching between Local (`localhost:8080`), Staging, and Production API URLs.

### 2. Backend Features & Endpoints (Go API)
- [ ] **Inspection Bookings Controller**:
  - Implement `/api/bookings` endpoints (Create booking, list tenant bookings, list landlord bookings, update booking status: confirmed/cancelled).
- [ ] **Real OTP Delivery Service**:
  - Integrate an SMS/Email service provider (e.g., Twilio, Termii, SendGrid, or SMTP) in [`auth_controller.go`](file:///home/chrisdev/Desktop/homehub-app/backend/controllers/auth_controller.go) for delivering real 6-digit OTP codes.
- [ ] **Google Auth Token Verification**:
  - Complete backend Google OAuth token validation against Google's token info APIs in `GoogleAuth` handler.
- [ ] **Lease & Escrow Data Persistence**:
  - Add GORM models and controllers for persisting signed lease agreements and escrow payment records in SQLite/Postgres.

### 3. Payment Gateway & Escrow Integration
- [ ] **Paystack / Flutterwave Integration**:
  - Integrate Paystack API for collecting security deposits and rent into escrow accounts directly from the app.
- [ ] **Payment Verification Webhooks**:
  - Add backend webhook listener (`POST /api/payments/webhook`) to handle payment success/failure notifications asynchronously.

---

## 🔵 Medium & Low Priority TODOs

### 4. Push Notifications & User Experience
- [ ] **Firebase Cloud Messaging (FCM)**:
  - Add FCM support for mobile push notifications (new chat messages, inspection booking updates, lease status changes).
- [ ] **Offline Caching & State Persistence**:
  - Cache property search queries and user bookmarks locally via Hive or SQLite for full offline browsing.

### 5. Mobile & Platform Release Configuration
- [ ] **Android Package Configuration**:
  - Update `applicationId` in `android/app/build.gradle.kts` and configure release signing configs.
- [ ] **iOS Permissions & Provisioning**:
  - Add `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, and `NSLocationWhenInUseUsageDescription` keys in `ios/Runner/Info.plist`.
- [ ] **App Store Assets & Icons**:
  - Replace default Flutter app icon and splash screens with branded HomeHub assets.

### 6. Testing, CI/CD & Deployment
- [ ] **Flutter Widget & Integration Tests**:
  - Add automated widget tests for key screens (`HomeScreen`, `PropertyDetailScreen`, `LoginScreen`).
- [ ] **Go API Unit & Integration Tests**:
  - Expand test suites under `backend/tests` covering auth, listing creation, and chat endpoints.
- [ ] **CI/CD Pipeline**:
  - Setup GitHub Actions workflow for linting, building Flutter APKs/web bundles, and running Go tests on PRs.
