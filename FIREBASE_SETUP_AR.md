# إعداد Firebase لمشروع شغل مخك

## ما تم تجهيزه في هذه النسخة
- إضافة `firebase_core` إلى `pubspec.yaml`.
- إضافة `lib/firebase_options.dart` بإعدادات تطبيق Android المسجل في مشروع Firebase `shaghel-mokh`.
- إضافة `FirebaseBootstrap` وتهيئة Firebase عند تشغيل التطبيق.
- استمرار فتح اللعبة محليًا إذا فشلت تهيئة Firebase، بدل إيقاف التشغيل بالكامل.
- حفظ `google-services.json` داخل `android_overlay/` لأن مجلد Android يُنشأ وقت GitHub Actions.
- إضافة خطوة في GitHub Actions تنسخ الملف إلى `android/app/` وتفعّل Google Services Gradle Plugin.
- ضبط `minSdk` إلى 24 كحد أدنى ليتوافق مع Firebase Android SDK 35 المستخدم في `firebase_core 5.1.0`.
- تثبيت Flutter stable 3.47.9 وJava 17 وإعداد ذاكرة Gradle وعدد workers لتقليل اختلافات بيئة البناء.
- إضافة صلاحية الإنترنت إلى Android Manifest.

## بيانات الربط
- Firebase Project ID: `shaghel-mokh`
- Android package: `com.shaghelmokh.shaghel_mokh`
- Firebase Android App ID: `1:55197254643:android:35a02175b705725ba30886`

## ما لم يتم تفعيله بعد
- Firebase Authentication (Google وEmail/Password).
- Cloud Firestore وقواعد الأمان.
- مزامنة بيانات اللاعب ونتائج اللعب.
- إعداد تطبيق Web منفصل للوحة الإدارة.
- OAuth Client وSHA-1/ SHA-256 لتسجيل الدخول بواسطة Google.

يجب تفعيل مزوّدي تسجيل الدخول وإنشاء Firestore من Firebase Console قبل اختبار هذه الخدمات. إعداد Google Sign-In غير مكتمل في ملف JSON الحالي لأن `oauth_client` فارغ؛ يجب إضافة SHA fingerprints من شهادة التوقيع المستخدمة فعليًا ثم تنزيل `google-services.json` المحدّث.

## تنبيه الاختبار
تم التحقق من سكربت Python وتهيئة Gradle على قوالب Kotlin DSL وGroovy تجريبية، كما تم التحقق من YAML. لم يتوفر Flutter SDK في بيئة إعداد هذه الحزمة؛ لذلك لم يتم تشغيل `flutter pub get` أو `flutter analyze` أو بناء APK فعلي هنا. يجب التحقق من النتائج عبر GitHub Actions قبل اعتماد APK.
