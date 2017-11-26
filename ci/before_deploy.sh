# This script takes care of building your crate and packaging it for release

set -ex

package() {
    local TARGET=$1 \
        src=$(pwd) \
        stage=

    case $TRAVIS_OS_NAME in
        linux)
            stage=$(mktemp -d)
            ;;
        osx)
            stage=$(mktemp -d -t tmp)
            ;;
    esac

    test -f Cargo.lock || cargo generate-lockfile

    cross build --target $TARGET --release
    cross rustc --bin $CRATE_NAME --target $TARGET --release -- -C lto

    cp target/$TARGET/release/$CRATE_NAME $stage/

    cd $stage
    tar czf $src/$CRATE_NAME-$TRAVIS_TAG-$TARGET.tar.gz *
    cd $src

    rm -rf $stage
}

for TARGET in "${TARGETS[@]}"; do
    package $TARGET
done
