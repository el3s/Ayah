# تطبيق القرآن الكريم - ورش وحفص

## 1. محتوى المشروع

تطبيق Flutter كامل للقرآن الكريم:
- عرض القرآن برواية ورش وحفص (بيانات جاهزة فـ `assets/data/`)
- تفسير الجلالين (يجلب تلقائيًا من `api.quran-tafseer.com` ويخزن محليًا)
- **الأذان التلقائي** حسب الموقع الجغرافي (يشتغل حتى والتطبيق مسكر)
- بحث، علامات مرجعية، آخر قراءة، إحصائيات
- تسبيح إلكتروني، اتجاه القبلة، أذكار، وضع الحفظ
- وضع ليلي/نهاري، تكبير/تصغير الخط

---

## 2. قبل ما تبدا: حاجات خاصك تزيدها بنفسك

المشروع جاهز 100% من ناحية الكود، لكن كاين 2 حاجات ما قدرتش نزيدهم أنا
(حقوق ملكية / حجم كبير):

### أ) الخطوط العربية (إجبارية)
حمّل من [مجمع الملك فهد](https://qurancomplex.gov.sa/) أو
[fonts.qurancomplex.gov.sa](https://fonts.qurancomplex.gov.sa) خط:
- `UthmanicHafs.ttf` → حطو فـ `assets/fonts/`
- `UthmanicWarsh.ttf` → حطو فـ `assets/fonts/`

بديل مجاني وسريع: خط "Amiri Quran" من Google Fonts (أقل دقة فرسم الوقف لكن مجاني ومرخص بالكامل).

### ب) ملفات صوت الأذان (إجبارية للميزة الأساسية)
حط ملفات mp3 فـ `assets/sounds/` بأسماء:
- `adhan_makkah.mp3`
- `adhan_madina.mp3`
- `adhan_alaqsa.mp3`

كاين نسخ مجانية ومرخصة (Public Domain / CC) فمواقع بحال Archive.org، دير بحث "adhan mp3 free license".

---

## 3. تجهيز بيئة العمل (مرة وحدة فقط)

```bash
# 1. حمل Flutter SDK
https://docs.flutter.dev/get-started/install

# 2. تأكد من التنصيب
flutter doctor

# 3. فمجلد المشروع
flutter pub get
```

---

## 4. تعديلات إجبارية فـ Android (مهمة بزاف للأذان التلقائي)

افتح `android/app/src/main/AndroidManifest.xml` وزيد هاد الصلاحيات
داخل `<manifest>` (قبل `<application>`):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
```

وداخل `<application>` زيد:

```xml
<receiver android:name="dev.fluttercommunity.plus.androidalarmmanager.AlarmBroadcastReceiver"
    android:exported="false"/>
<receiver android:name="dev.fluttercommunity.plus.androidalarmmanager.RebootBroadcastReceiver"
    android:enabled="true" android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
    </intent-filter>
</receiver>
```

**غيّر رقم الـ `minSdkVersion` فـ `android/app/build.gradle` إلى 21 على الأقل.**

---

## 5. تجربة التطبيق قبل البناء

```bash
flutter run
```

وصلو الهاتف بالكابل، وفعّل "USB Debugging" من إعدادات المطور فالهاتف.

---

## 6. بناء APK (للتجربة المباشرة / التوزيع اليدوي)

```bash
flutter build apk --release
```

الملف غادي يطلع فـ:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 7. بناء AAB (إجباري للنشر فـ Google Play Store)

### أ) أنشئ مفتاح التوقيع (مرة وحدة، احتفظ بيه للأبد):

```bash
keytool -genkey -v -keystore ~/quran-app-key.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias quran_app
```

### ب) أنشئ ملف `android/key.properties`:

```properties
storePassword=<الباسورد ديالك>
keyPassword=<الباسورد ديالك>
keyAlias=quran_app
storeFile=/home/USERNAME/quran-app-key.jks
```

### ج) عدّل `android/app/build.gradle` (زيد قبل `android {`):

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

وداخل `android {`:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

### د) غيّر اسم الحزمة (Package Name) من `com.example.quran_karim_app`
لاسم خاص بيك (مثلا `com.yourname.quranapp`) فـ:
- `android/app/build.gradle` (applicationId)
- `android/app/src/main/AndroidManifest.xml`
- مجلدات `android/app/src/main/kotlin/...`

### هـ) بناء AAB:

```bash
flutter build appbundle --release
```

الملف: `build/app/outputs/bundle/release/app-release.aab`
هادشي لي كتصعدو لـ Google Play Console.

---

## 8. ما عندكش Windows/Mac؟ (بناء أونلاين مجاني)

استعمل **Codemagic** (مجاني لـ 500 دقيقة بناء فالشهر):
1. https://codemagic.io → سجل بحساب GitHub
2. ارفع المشروع لـ GitHub repo
3. ربطو مع Codemagic → اختار "Flutter App" → زيد ملف التوقيع فالإعدادات
4. اضغط "Start new build" → غيرجعلك APK/AAB جاهز للتحميل

---

## 9. النشر فـ Google Play Store - Checklist

1. حساب مطور Google Play (25$ مرة وحدة، مدى الحياة): play.google.com/console
2. سياسة الخصوصية (Privacy Policy) - إجبارية حتى لتطبيق ديني بسيط
   (استعمل مولد مجاني بحال privacypolicygenerator.info)
3. لقطات شاشة (Screenshots) - على الأقل 2 لكل حجم هاتف
4. أيقونة التطبيق 512x512
5. وصف التطبيق بالعربية والإنجليزية
6. تصنيف المحتوى (Content Rating) - جاوب على استبيان Google
7. صعّد ملف `.aab` فقسم "Production" أو "Internal testing" أولاً للتجربة
8. انتظر المراجعة (عادة من يوم لـ 7 أيام)

**ملاحظة مهمة**: طلب صلاحية الموقع (GPS) خاصو يكون واضح فوصف التطبيق
لأن Google كيراجع بدقة التطبيقات لي كتطلب صلاحيات حساسة.

---

## 10. بنية المشروع

```
lib/
  core/            - الثوابت والألوان والخطوط
  data/
    models/        - نماذج البيانات
    repositories/  - كل الاستعلامات (قرآن، تفسير، صلاة، مستخدم)
    database_helper.dart - SQLite + تعبئة أولية من JSON
  providers/       - إدارة الحالة (Provider)
  services/        - الموقع + الأذان التلقائي
  screens/         - كل شاشات التطبيق
assets/
  data/            - warsh.json و hafs.json
  fonts/           - خاصك تزيدهم (انظر القسم 2)
  sounds/          - خاصك تزيدهم (انظر القسم 2)
```
