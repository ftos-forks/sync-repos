#/usr/bin/env bash
org="ftos-forks"
file="rrepos.json"


echo "[" > output.txt
gh api /orgs/ftos-forks/repos --jq '.[].name' --paginate > ${file}

while IFS= read -r line
do
  x=$(curl -u dariusxdragoi:acceces https://api.github.com/repos/ftos-forks/${line}) 
  echo $x > ./info.json
  y=$(jq '.parent.full_name' info.json | tr -d '"')
  if [ "$y" != "null" ]
  then
    echo "    {" >> output.txt
    echo "        \"Source\": \"git@github.com:$y\"," >> output.txt
    echo "        \"Destination\": \"git@github.com:ftos-forks/$line\"" >> output.txt
    echo "    }," >> output.txt
  fi
done < ${file}

sed '$d' < output.txt > last.txt
echo "    }" >> last.txt
echo "]" >> last.txt
cat ./last.txt
