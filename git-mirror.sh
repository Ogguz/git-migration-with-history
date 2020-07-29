#!/usr/bin/env bash

die() {
        echo "$*" >&2
        exit 2
}

warn() {
        echo "$*" >&1
}

echo "Source repo url"
read oldRepoUrl
echo "New repo name - not url name!"
read newRepoName
echo "Now time for new repo url..."
read newRepoUrl

migrate() {
  echo "Clone with mirror is running..."
  git clone --mirror ${oldRepoUrl} ${newRepoName} || die "Either mkdir ${newRepoName} or clone ${oldRepoUrl} failed"
  cd ${newRepoName} && git remote remove origin || die "Could not removed old remote origin, please check file paths and git folder."
  echo "Old repo connection removed"
  git remote add origin ${newRepoUrl}
  echo "Pushing..."
  git push --all && git push --tags || die "git push failed"
  echo "Cleaning..."
  cd .. && rm -rf ${newRepoName}
  echo "All done... Now cloning from new gitlab server..."
  git clone ${newRepoUrl} ${newRepoName} || warn "Couldnt clone ${newRepoName}"
  echo "$(pwd)/${newRepoName} is ready"
}

usage(){
  echo "Error. \n
     usage: \n
     ./git-mirror.sh \n
     1- enter source repo url, \n
     2- Only repo name! \n
     3- Destination repo url!"
  exit 2
}

if [[ -z $oldRepoUrl || -z $newRepoName || -z $newRepoUrl ]];then
  usage
else
  migrate || usage
fi
