# تقرير إصلاح بناء Android — شغل مخك

## ملخص الفشل المرصود

في تشغيل GitHub Actions رقم 41، وصلت المهمة إلى خطوة `Build release APK` ثم فشل Gradle أثناء `assembleRelease` وأعاد `exit code 1`. الصفحة العامة تعرض حالة الخطأ، لكن سجل Gradle التفصيلي الكامل غير متاح دون جلسة GitHub؛ لذلك لا يمكن الجزم برسالة Gradle الداخلية التي سببت الفشل اعتمادًا على لقطة نهاية السجل وحدها.

## ما تم إصلاحه في هذه الحزمة

1. تثبيت بيئة CI على Flutter stable `3.47.9` وJava `17` بدل الاعتماد على إصدار stable متغير بين التشغيلات.
2. ترقية GitHub Actions إلى إصدارات تعمل على Node.js 24: `checkout@v7` و`setup-java@v6` و`upload-artifact@v7`.
3. نقل إعداد Java/Caching إلى ما بعد إنشاء مجلد Android حتى يكون `gradle-wrapper.properties` موجودًا عند احتساب كاش Gradle.
4. إضافة `minSdk >= 24` صراحةً داخل `android/app`؛ يتوافق ذلك مع متطلبات Firebase Android SDK 35 المستخدم في `firebase_core 5.1.0`.
5. تحسين سكربت Firebase ليكون idempotent، ويتحقق من Package Name وملف JSON، ويضيف Google Services plugin بعد Android application plugin.
6. ضبط ذاكرة Gradle وعدد workers، وإضافة `--verbose` إلى بناء APK حتى تظهر رسالة الخطأ الأصلية إذا استمر الفشل.
7. إضافة concurrency لمنع تشغيل عشرات عمليات البناء المتزامنة عند رفع الملفات على دفعات، وإضافة رفع مخرجات التشخيص عند فشل المهمة.
8. المحافظة على `lib/` و`pubspec.yaml` و`test/` أثناء توليد ملفات Android؛ لا يتم حذف مجلد الاختبارات الموجود.

## الفحوصات المنفذة محليًا

- `python3 -m py_compile tool/configure_android_firebase.py`: نجح.
- اختبار سكربت Gradle على قوالب Kotlin DSL وGroovy: نجح، بما في ذلك تكرار التشغيل دون إضافة plugins مكررة.
- التحقق من Firebase JSON وتطابق `com.shaghelmokh.shaghel_mokh`: نجح.
- تحليل YAML و`bash -n` للخطوات المضمنة: نجح.
- مقارنة الملفات مع `shaghel_mokh_v1_fixed.zip`: لا توجد ملفات أصلية مفقودة.

## ما لم يتم التحقق منه

لم يتوفر Flutter/Dart SDK أو Android SDK في بيئة إعداد الحزمة، لذلك لم يتم تنفيذ `flutter pub get` أو `flutter analyze` أو بناء APK فعلي هنا. يجب رفع ملفات الإصلاح إلى GitHub وتشغيل Workflow مرة واحدة للتحقق النهائي.
