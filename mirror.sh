# Batch script for unofficial mirror of pLaTeX in UTF-8.
# Public domain.

REPO_TOP=$(pwd)
ORIGINAL_DIR="$REPO_TOP/platex-original/"
TARGET_DIR="$REPO_TOP/platex/"
ORIGINAL_BRANCH="master"

convert_platex() {
  # make sure to cleanup the existing one
  rm -rf $TARGET_DIR
  mkdir -p $TARGET_DIR

  # copy the directory structure
  find $ORIGINAL_DIR -type d -name .git -prune -o -type d | sed "s#$ORIGINAL_DIR##" \
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
}

main() {
  echo "mirror: start batch job ($(date '+%F %T'))"

  # get the commit list of updated commits
  cd $ORIGINAL_DIR
  git checkout $ORIGINAL_BRANCH
  echo "mirror: Pulling the current HEAD"
  git pull
  local log=$(git log --oneline $(cat $REPO_TOP/latest.txt)..HEAD)

  if [[ -z "$log" ]]; then
    echo "mirror: No updates"
    return 0
  fi

  cd $REPO_TOP
  echo "$log" | tac | while read commit; do
    local id=$(cut -d' ' -f 1 <<<${commit})

    # checkout to the target commit
    cd $ORIGINAL_DIR
    git checkout $id > /dev/null 2> /dev/null

    # convert!!
    cd $REPO_TOP
    convert_platex

    # then commit
    cd $REPO_TOP
    git add -A
    git commit -m "$commit"
  done

  # finalize
  cd $ORIGINAL_DIR
  git checkout $ORIGINAL_BRANCH > /dev/null 2> /dev/null
  git rev-parse HEAD > $REPO_TOP/latest.txt

  cd $REPO_TOP
  git push
}

# execute
main
