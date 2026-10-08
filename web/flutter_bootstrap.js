{{flutter_js}}
{{flutter_build_config}}

// Override del flutter_bootstrap.js que genera `flutter build web`.
// Objetivo: sacar el loader HTML/CSS de index.html (#app-loader) recién
// cuando el engine terminó de pintar su primer frame, y no antes.
// https://docs.flutter.dev/platform-integration/web/initialization
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();

    window.addEventListener(
      "flutter-first-frame",
      function () {
        const loader = document.getElementById("app-loader");
        if (!loader) return;
        loader.addEventListener("transitionend", () => loader.remove(), {
          once: true,
        });
        loader.classList.add("app-loader--hidden");
      },
      { once: true }
    );
  },
});
