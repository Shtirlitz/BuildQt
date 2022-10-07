# BuildQt - docker environment to build Qt Apps
Ready-to-use Qt cross-compile environment in Docker/GitLab-CI

The project can be used as a set of containers for Qt apps building in GitLab environment.
Based on mxe.cc project.

## Files
* `Dockerfile` - for building basic image with MXE sources and dependencies (tag: `qtdeps`)
* `Dockerfile.win64s` - for building image **Windows 64bit Cross-compiled Statically Linked** based on qtdeps (tag: `win64s`)
* `Dockerfile.win64d` - for building image **Windows 64bit Cross-compiled Dynamically Linked** based on qtdeps (tag: `win64d`)
* `.gitlab-ci.yml` - YAML-file to define **GitLab-CI** pipelines for images building (all stages by default set to manual because MXE Qt building is time consuming procedure, use it carefully).

## How to use
* Step 0: Create new project `buildqt` in GitLab for Qt container building and place this repository files to it.
* Step 1: Use manual action in `buildqt` pipeline to build `qtdeps` image and be sure that it successfully built and placed into GitLab Container Registry.
* Step 2: Build based on `qtdeps` next one docker image (`win64d` or `win64s`) to prepare Qt build environment. Check the GitLab Container Registry and be sure that image successfully placed to it and tagged.
* Step 3: If you haven't had qmake/cmake deploy settings inside of your Qt App, place script `redist_win64d.sh` in the root of your Qt App repository and correct it. The redist shell script place app (EXE) and dependencies (DLLs) from container to project artifacts folder `build`. 
* Step 4: Use the proper build image (`win64d` or `win64s`) in your Qt App GitLab-repository for building, results will be placed in pipeline' artifacts archive.

Example of `.gitlab-ci.yml` file of Qt App repository (**Windows 64bit Cross-compiled Dynamically Linked**):
```
build:
  stage: build
  image: docker:19
  variables:
    GIT_SUBMODULE_STRATEGY: recursive
  services: 
    - docker:19-dind
  script:
    - docker login -u $CI_DEPLOY_USER -p $CI_DEPLOY_PASSWORD $CI_REGISTRY
    - docker run -v $(pwd):/src -v $(pwd)/build:/build -w /src $CI_REGISTRY/place project group here/buildqt/buildqt:win64d /bin/bash -c "cd /src && qmake YourApp.pro && make release -j $(nproc) && chmod +x ./redist_win64d.sh && ./redist_win64d.sh"
  artifacts:
    name: "$CI_BUILD_REF_NAME-$CI_COMMIT_SHORT_SHA"
    paths:
      - build
    expire_in: 1 week
  tags:
    - shared
    - docker
```

Example of `redist_win64d.sh` script of Qt App repository:
```
CWD=${PWD}
mkdir ${CWD}/build/plugins
mkdir ${CWD}/build/plugins/platforms
cp /opt/mxe/usr/x86_64-w64-mingw32.shared/qt6/plugins/platforms/qwindows.dll ${CWD}/build/plugins/platforms/
cp ${CWD}/app/release/YourApp.exe ${CWD}/build/
cd /opt/mxe/usr/x86_64-w64-mingw32.shared/bin
cp icudt66.dll icuin66.dll icuuc66.dll libbz2.dll libfreetype-6.dll libgcc_s_seh-1.dll libglib-2.0-0.dll libharfbuzz-0.dll libiconv-2.dll libintl-8.dll  libpcre-1.dll libpcre2-16-0.dll libpng16-16.dll libstdc++-6.dll libwinpthread-1.dll libzstd.dll zlib1.dll ${CWD}/build/
cp -r /opt/mxe/usr/x86_64-w64-mingw32.shared/qt6/plugins/imageformats ${CWD}/build/plugins/
cd /opt/mxe/usr/x86_64-w64-mingw32.shared/qt6/bin
cp Qt6Core.dll Qt6Gui.dll Qt6Network.dll Qt6Widgets.dll ${CWD}/build/
```
