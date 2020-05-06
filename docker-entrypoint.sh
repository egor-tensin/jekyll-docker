#!/usr/bin/env bash

# We make sure that the container is run by the same user as the one who built
# the image (so that /project is seamlessly writable).
# Unless, of course, the image was built by root, in which case we fall back
# to a custom user with UID 999.

set -o errexit -o nounset -o pipefail

echo 'User info:'
id
uid="$( id -u )"
gid="$( id -g )"

if [ "$uid" = 0 ]; then
    echo 'Going to run as jekyll instead of root, fixing /project permissions...'
    chown -R -- jekyll:jekyll /project
    exec gosu jekyll "$0" "$@"
fi

if [ "$uid" != "$JEKYLL_UID" ] && [ "$JEKYLL_UID" != 0 ]; then
    echo "User jekyll was created with ID $JEKYLL_UID, are you sure you want to run the container with UID $uid?"
    exit 1
fi

if [ "$gid" != "$JEKYLL_GID" ] && [ "$JEKYLL_GID" != 0 ]; then
    echo "Group jekyll was created with ID $JEKYLL_GID, are you sure you want to run the container with GID $gid?"
    exit 1
fi

echo "The container is running with UID $uid and GID $gid, just as planned..."
exec "$@"
