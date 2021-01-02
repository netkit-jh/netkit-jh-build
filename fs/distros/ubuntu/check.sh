while read p; do
  apt-cache show $p
done <packages-list
