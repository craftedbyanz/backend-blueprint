# docker login
# docker build -t annt17/flask-app:1.0 .


# Get Commit date
COMMIT_DATE_FORMAT="$(date +"%y.%m%d.%H%M")"
# Get current branch
CUR_BRANCH=`git rev-parse --abbrev-ref HEAD | sed 's/\//\-/g'`
# Get Commit ID
COMMIT_ID=`git log | head -1 | sed s/'commit '//`
SUB_COMMIT_ID=$(echo $COMMIT_ID | cut -c 1-7)

# Image name
IMAGE="annt17/flask-app:1.0-${COMMIT_DATE_FORMAT}_${CUR_BRANCH}_${SUB_COMMIT_ID}"

echo "Building image $IMAGE\n"

# Build Image
docker build . -t $IMAGE

# Push Image
docker push $IMAGE
