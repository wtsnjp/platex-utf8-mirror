# Build script for unofficial mirror of pLaTeX in UTF-8.
# Public domain.

# variables
ORIGINAL_DIR='./platex-original/'
TARGET_DIR='./platex/'

# copy the directory structure
gfind $ORIGINAL_DIR -type d -name .git -prune -o -type d | gsed 's#./platex-original/##' \
  | ggrep -v .git | xargs -I % mkdir -p $TARGET_DIR%

# copy binary files
gfind $ORIGINAL_DIR -type d -name .git -prune -o -type f -name '*.pdf' -o -name '*.dvi' \
  | ggrep -v .git | xargs -I % gcp -f % $TARGET_DIR

# convert encoding for all text files
gfind $ORIGINAL_DIR -type d -name .git -prune -o -type f -not -name '*.pdf' -not -name '*.dvi' \
  | ggrep -v .git | while read line
do
  target=$(echo $line | gsed -e "s#$ORIGINAL_DIR#$TARGET_DIR#g")
  iconv -f ISO-2022-JP -t UTF8 $line > $target
done

# copy the .gitignore
gcp $ORIGINAL_DIR.gitignore $TARGET_DIR.gitignore
