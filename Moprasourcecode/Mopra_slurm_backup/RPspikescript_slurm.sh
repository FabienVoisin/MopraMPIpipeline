#!/bin/sh

#SBATCH -p test
#SBATCH -N 1
#SBATCH -n 1 
#SBATCH --mem=6GB
#SBATCH --time=2:00:00

#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@adelaide.edu.au

#First I convert all the raw data onto sdfits table
module load IDL 

##---folder is the inline argument here ! ##--
cd ${HOMEMOPRADATA}/${folder}
RAWSDFITSFOLDER="$(basename ${folder} rpf)rawsdfits"
echo ${RAWSDFITSFOLDER}
mkdir ${HOMEMOPRADATA}/${RAWSDFITSFOLDER}
for file in *.rpf; do
  echo "$file"
  rp2sdfits ./"$file" "./$(basename ${file} .rpf).sdfits"
done

mv *.sdfits ${HOMEMOPRADATA}/${RAWSDFITSFOLDER}/



### --I need then to copy the master RPspike.pro into the folder ###

cp ${FASTDIR}/Mopra/script/IDLscript/RPspike_fabien.pro ${HOMEMOPRADATA}/${RAWSDFITSFOLDER}/RPspike_template.pro

cd ${HOMEMOPRADATA}/${RAWSDFITSFOLDER}
pwd
### --Now I first change the folder to look at 
sed -i "s|INPUTDATA|${RAWFITSFOLDER}|g" RPspike_template.pro

### --Now I need to group all the files into an array
SDFITS=( $(ls *.sdfits))
echo ${SDFITS[@]} 
sed -i "s|LIST_OF_SDFITS_FILES|${SDFITS[@]}| " RPspike_template.pro

###---Finally we run the RPSpike IDL script to remove issues ....
idl -e RPspike_template 

