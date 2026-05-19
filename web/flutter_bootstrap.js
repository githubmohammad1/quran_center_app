// {{flutter_js}}
// {{flutter_build_config}}

// // 🚀 [تعديل الجودة]: التحكم بآلية إقلاع المحرك وتمرير رندر HTML للتخلص من حجب صور الـ QR
// _flutter.loader.load({
//   onEntrypointLoaded: function(engineInitializer) {
//     engineInitializer.initializeEngine({
//       renderer: "html" // تفعيل محرك الـ HTML برمجياً بشكل دائم وصارم
//     }).then(function(appRunner) {
//       appRunner.runApp();
//     });
//   }
// });