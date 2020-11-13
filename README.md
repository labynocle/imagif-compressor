# imagif-compressor

Use the docker image [labynocle/imagif-compressor](https://hub.docker.com/repository/docker/labynocle/imagif)
to:

* lossless compress all png and jpeg files
* reduce the size of the gif files

:information_source: permissions and owner will be preserved!

## How to use it

If you want to compress all files in a given directory, launch the container as
following:

```
docker run \
  --rm \
  -v /path/to/your/directory:/data-volume \
  labynocle/imagif-compressor:latest
```

eg:

```
$ docker run --rm -v /home/erwan/images:/data-volume labynocle/imagif-compressor:latest
SAME - play-button.png is the same when is compressed
COMPRESSED - money.gif compressed with a reduction of 5.13%
BIGGER - bg-analysts-report-mobile.jpg seems to be bigger after compression
BIGGER - montebourg.jpeg seems to be bigger after compression
IGNORE - sondage_primaires.csv could not be managed
BIGGER - analyst-article-gartner.jpg seems to be bigger after compression
```

But you can reduce to check only given files:

```
docker run \
  --rm \
  -v /path/to/your/directory:/data-volume \
  -e LIST_FILES="file1.png file2.png"
  labynocle/imagif-compressor:latest
```

eg:

```
$ docker run --rm -v /home/erwan/images:/data-volume -e LIST_FILES="play-button.eeepng play-button.png" labynocle/imagif-compressor:latest
IGNORE - /data-volume/play-button.eeepng does not exist
SAME - play-button.png is the same when is compressed
```

## Manage the image with Docker Hub

* Update the version `make set NEW_VERSION=0.0.1`
* Commit the changes with a commit message: `v0.0.1`
* Build the new version `make docker-build`
* Push it to `make push-to-dockerhub IMAGIF_IMAGE_MORE_TAGS=latest`
