# Build script for unofficial mirror of pLaTeX in UTF-8.
# Public domain.

# variables
ORIGINAL_DIR='./platex-original/'
TARGET_DIR='./platex/'

# copy the directory structure
find $ORIGINAL_DIR -type d -name .git -prune -o -type d | sed 's#./platex-original/##' \
  | grep -v .git | xargs -I % mkdir -p $TARGET_DIR%

# copy binary files
find $ORIGINAL_DIR -type d -name .git -prune -o -type f -name '*.pdf' -o -name '*.dvi' \
  | grep -v .git | xargs -I % cp -f % $TARGET_DIR

# convert encoding for all text files
find $ORIGINAL_DIR -type d -name .git -prune -o -type f -not -name '*.pdf' -not -name '*.dvi' \
  | grep -v .git | while read file
do
  target=$(echo $file | sed -e "s#$ORIGINAL_DIR#$TARGET_DIR#g")
  if [[ $(file -i $file | grep utf-8) ]]; then
    cp -f $file $target
  else
    iconv -f ISO-2022-JP -t UTF8 $file > $target
  fi
done

# copy the .gitignore
cp -f $ORIGINAL_DIR.gitignore $TARGET_DIR.gitignore
