#!/bin/bash

# exit on error
set -e

docker compose down -v

INSTALLTATION_DIR=`pwd`

docker run -it --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "$INSTALLTATION_DIR":/usr/src/code/appwrite:rw \
    --entrypoint="upgrade" \
    appwrite/appwrite --http-port=8080 --https-port=443 --interactive=N --no-start=true

# restore _APP_SETUP
sed -i.bak "s/_APP_CONSOLE_WHITELIST_IPS=/_APP_CONSOLE_WHITELIST_IPS=\n_APP_SETUP=1-click-gitpod/g" .env

VERSION=`grep "image: appwrite/appwrite:" docker-compose.yml | uniq | sed "s/^.*image: appwrite\/appwrite://g"`
git checkout -b feat-$VERSION
git add .env docker-compose.yml
git commit -m "feat: update to $VERSION release"

# confirm before proceeding
read -p "Push to origin? (y/n) " -n 1 -r

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

git push -u origin HEAD

echo Link to create PR:
echo "https://github.com/appwrite/integration-for-gitpod/compare/main...feat-$VERSION?expand=1&body=%23%23%20What%20does%20this%20PR%20do%3F%0A%0AUpgrade%20to%20%5B$VERSION%5D%28https%3A%2F%2Fgithub.com%2Fappwrite%2Fappwrite%2Freleases%2Ftag%2F$VERSION%29%20release.%0A%0A%23%23%20Test%20Plan%0A%0AManual%0A%0A%23%23%20Related%20PRs%20and%20Issues%0A%0ANone%0A%0A%23%23%23%20Have%20you%20read%20the%20%5BContributing%20Guidelines%20on%20issues%5D%28https%3A%2F%2Fgithub.com%2Fappwrite%2Fappwrite%2Fblob%2Fmaster%2FCONTRIBUTING.md%29%3F%0A%0AYes"
echo
echo PR Subject:
echo "feat: update to $VERSION release"
echo
echo PR Body:
echo "## What does this PR do?

Upgrade to [$VERSION](https://github.com/appwrite/appwrite/releases/tag/$VERSION) release.

## Test Plan

Manual

## Related PRs and Issues

None

### Have you read the [Contributing Guidelines on issues](https://github.com/appwrite/appwrite/blob/master/CONTRIBUTING.md)?

Yes"