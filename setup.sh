#!/bin/bash
export SCRAM_ARCH=slc6_amd64_gcc630
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_0_2/src ] ; then 
 echo release CMSSW_10_0_2 already exists
else
scram p CMSSW CMSSW_10_0_2
fi
cd CMSSW_10_0_2/src
eval `scram runtime -sh`

curl -s --insecure https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/EGM-RunIISpring18wmLHEGS-00001 --retry 2 --create-dirs -o Configuration/GenProduction/python/EGM-RunIISpring18wmLHEGS-00001-fragment.py 
[ -s Configuration/GenProduction/python/EGM-RunIISpring18wmLHEGS-00001-fragment.py ] || exit $?;

scram b
cd ../../
seed=$(date +%s)
cmsDriver.py Configuration/GenProduction/python/EGM-RunIISpring18wmLHEGS-00001-fragment.py --fileout file:EGM-RunIISpring18wmLHEGS-00001.root --mc --eventcontent RAWSIM,LHE --datatier GEN-SIM,LHE --conditions 100X_upgrade2018_realistic_v10 --beamspot Realistic25ns13TeVEarly2017Collision --step LHE,GEN,SIM --nThreads 8 --geometry DB:Extended --era Run2_2018 --python_filename EGM-RunIISpring18wmLHEGS-00001_1_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${seed}%100)" -n 1338 || exit $? ; 

