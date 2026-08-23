# curl-cffi 0.15.0 fails its pythonImportsCheck on darwin: the cffi wrapper is
# linked against `@rpath/libcurl-impersonate.4.dylib` but the .so ships with no
# LC_RPATH at all, so dlopen can never resolve it. Stamp the curl-impersonate
# lib dir onto the wrapper in postFixup (runs before installCheck, so the import
# check passes). yt-dlp depends on curl-cffi, so without this nothing builds.
# Drop once nixpkgs fixes the rpath upstream.
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      curl-cffi = pyprev.curl-cffi.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          install_name_tool -add_rpath ${final.curl-impersonate}/lib \
            "$out/${pyfinal.python.sitePackages}/curl_cffi/_wrapper.abi3.so"
        '';
      });
    })
  ];
}
