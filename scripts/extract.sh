#/usr/bin/env bash
org="ftos-forks"
file="rrepos.json"



gh repo list ${org} --json name | jq '.[].name' | tr -d '"' > ${file}

while IFS= read -r line
do
  x=$(curl -u dariusxdragoi:acceces https://api.github.com/repos/ftos-forks/${line}) 
  echo $x > ./info.json
  y=$(jq '.parent.full_name' info.json | tr -d '"')
  if [ "$y" != "null" ]
  then
    echo "ftos-forks/$line is forked from $y"
  fi
done < ${file}
