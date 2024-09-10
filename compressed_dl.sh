#!/bin/bash

#compressed retrieval of vesuvius data using remote server with ssh access and python,opencv,numpy,wget,cjxl
#e.g. bash compressed_dl.sh yourserver.xyz full-scrolls/Scroll1/PHercParis4.volpkg/volumes_masked/20230205180739

host="yourownremotehost.something"
source="https://dl.ash2txt.org/full-scrolls/Scroll1/PHercParis4.volpkg/volumes_masked/20230205180739/"
target_dir="~/Downloads/dl.ash2txt.org/full-scrolls/Scroll1/PHercParis4.volpkg/volumes_preview/20230205180739/"

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 3 ] || die "3 arguments required, $# provided. Usage: $0 start max step"

if [ ! -d ${target_dir} ]; then
  echo "target directory does not exist:"
  echo $target_dir
  exit 1
fi

min=${1}
max=${2}
step=${3}

echo "host: ${host}"
echo "source ${source}"
echo "process: ${min} to ${max} with step ${step}"

remote_tmp=$(ssh ${host} mktemp -d -t lavastream.tmp.XXXXXXXXXX)

echo "remote_tmp: ${remote_tmp}"

cands="$(seq -f %05.0f ${min} ${step} ${max})"

scp halfscale.py "${host}:${remote_tmp}/"

last_n="init"

for n in $cands
do
    if [ -f "${target_dir}/${n}.jxl" ]
    then
        echo "skipping $n"
    else
        echo "processing $n"
        ssh ${host} "wget -nv ${source}/$n.tif -O ${remote_tmp}/img.tif && flock /tmp/lavastream.python.lock python ${remote_tmp}/halfscale.py -i ${remote_tmp}/img.tif -o ${remote_tmp}/half.pgm && flock /tmp/lavastream.cjxl.lock cjxl -e 2 -q 100 ${remote_tmp}/half.pgm ${remote_tmp}/half.jxl"
        wait
        ssh ${host} "mv ${remote_tmp}/half.jxl ${remote_tmp}/half_transit.jxl"
        if [ ! "$last_n" = "init" ]; then
            mv ${target_dir}/${last_n}_tmp.jxl ${target_dir}/${last_n}.jxl
        fi
        scp ${host}:${remote_tmp}/half_transit.jxl ${target_dir}/${n}_tmp.jxl &
        echo "started transfer of $n"
        last_n=${n}
    fi
done

wait
if [ ! "$last_n" = "init" ]; then
    mv ${target_dir}/${last_n}_tmp.jxl ${target_dir}/${last_n}.jxl
fi

rm -rf ${remote_tmp}
