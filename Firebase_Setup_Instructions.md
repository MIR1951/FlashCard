# Firebase O'rnatish Yo'riqnomasi

## 1. Firebase Loyihasi Yaratish

1. [Firebase Console](https://console.firebase.google.com/) ga kiring
2. "Add project" tugmasini bosing
3. Loyiha nomini kiriting (masalan: "FlashCard-App")
4. Google Analytics sozlamalarini tanlang (ixtiyoriy)
5. Loyihani yarating

## 2. iOS Ilovasi Qo'shish

1. Firebase loyihasida "Add app" tugmasini bosing
2. iOS belgisini tanlang
3. Bundle ID ni kiriting: `com.yourcompany.FlashCard`
4. App nickname kiriting: "FlashCard iOS"
5. "Register app" tugmasini bosing

## 3. Konfiguratsiya Fayli Yuklab Olish

1. `GoogleService-Info.plist` faylini yuklab oling
2. Joriy loyihadagi `GoogleService-Info.plist` faylini o'chiring
3. Yuklab olingan haqiqiy faylni Xcode loyihasiga qo'shing
4. Faylni FlashCard target ga qo'shilganligini tekshiring

## 4. Firebase SDK Qo'shish

### Swift Package Manager orqali:

1. Xcode da loyihani oching
2. File → Add Package Dependencies...
3. URL kiriting: `https://github.com/firebase/firebase-ios-sdk`
4. Quyidagi paketlarni tanlang:
   - FirebaseAuth
   - FirebaseCore
   - FirebaseFirestore (kelajakda foydalanish uchun)

### Package.swift ga qo'lda qo'shish:

```swift
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0")
],
targets: [
    .target(
        name: "FlashCard",
        dependencies: [
            .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
            .product(name: "FirebaseCore", package: "firebase-ios-sdk")
        ]
    )
]
```

## 5. Authentication Sozlash

1. Firebase Console da Authentication bo'limiga o'ting
2. "Get started" tugmasini bosing
3. "Sign-in method" tabini tanlang
4. "Email/Password" ni yoqing
5. "Email link (passwordless sign-in)" ni ham yoqish mumkin

## 6. Xavfsizlik Qoidalari (ixtiyoriy)

Firestore uchun:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 7. Test Qilish

1. Loyihani build qiling: `Cmd+B`
2. Simulatorda ishga tushiring: `Cmd+R`
3. Ro'yxatdan o'tish funksiyasini test qiling
4. Kirish/Chiqish funksiyalarini test qiling

## Muhim Eslatmalar

- `GoogleService-Info.plist` fayli Git da saqlanmasligi kerak (.gitignore ga qo'shing)
- Firebase Console da test email manzillarini oldindan ro'yxatga olish mumkin
- Email verification yoqilgan bo'lsa, foydalanuvchilar emailni tasdiqlashlari kerak
- Production da email va parol qoidalarini sozlang

## Xatoliklar va Yechimlari

### "No Firebase App" xatosi:
- `FirebaseApp.configure()` `AppDelegate` yoki `@main` faylida chaqirilganligini tekshiring
- `GoogleService-Info.plist` fayli to'g'ri qo'shilganligini tekshiring

### Build xatoliklari:
- Firebase SDK versiyasini tekshiring
- iOS deployment target ni kamida 11.0 ga o'rnating
- Package dependencies ni yangilang

### Authentication xatoliklari:
- Firebase Console da email/password authentication yoqilganligini tekshiring
- Internet ulanishini tekshiring
- API kalit va loyiha ID ni tekshiring

## Qo'shimcha Imkoniyatlar

Kelajakda qo'shish mumkin:
- Google Sign-In
- Apple Sign-In
- Phone Authentication
- Email Verification
- Password Reset
- Firestore Database
- Cloud Storage
- Push Notifications 