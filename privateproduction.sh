#!/bin/bash

# Define number of events
export NUMBEREVENTS=10000000

# Define workdir
export WORKDIR=$1

# Define gridpack location, warning if you are using crab, requires global accessible gridpack
# If running locally you can also set a local gridpack location
export GRIDPACKLOC=/afs/cern.ch/work/j/jhkim/gridpack/Z_ee_NNPDF31_13TeV_M_20.tgz

# Use crab for grid submitting, adjust crabconfig.py accordingly beforehand
export USECRAB="True"
#export USECRAB="False"

######### Do not change anything behind this line ###############

export STARTDIR=`pwd`
echo "Start dir was:"
echo $STARTDIR

echo "Workdir set is:" 
echo $WORKDIR
mkdir -p $WORKDIR
echo "Created workdir"
cd $WORKDIR
echo "Changed into workdir"

echo "Install CMSSW in workdir"
source /cvmfs/cms.cern.ch/cmsset_default.sh 
scram project CMSSW_10_0_2
cd CMSSW_10_0_2/src
git clone git@github.com:jhkim06/PrivatePhotosInterface.git GeneratorInterface
eval `scramv1 runtime -sh`
echo "Loaded CMSSW_10_0_2"

echo "Copy run script to workdir"
#mkdir -p GeneratorInterface/LHEInterface/data/
#cp $STARTDIR/run_generic_tarball_cvmfs.sh GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh

echo "Change number of events in python config to"
echo $NUMBEREVENTS
sed -e "s/#NUMBEREVENTS#/${NUMBEREVENTS}/g" $STARTDIR/pythonLHEGEN_${1}_cfg_draft.py > ./pythonLHEGEN_cfg_eventsInserted.py

if [ $USECRAB = "True" ]; then
    echo "Will use crab submission, adjust crabconfig.py accordingly if problems arise"

        echo "Copy gridpack for production to workdir, so that crab can transfer it also"
        cp $GRIDPACKLOC Z_ee_NNPDF31_13TeV_M_20.tgz
    echo "Add gridpack location to python config and copy cmssw python config to workdir"
    sed -e "s~#GRIDPACKLOCATION#~../Z_ee_NNPDF31_13TeV_M_20.tgz~g" ./pythonLHEGEN_cfg_eventsInserted.py > ./pythonLHEGEN_cfg.py

    echo "Scram b and start of LHEGEN production"
    scram b -j 4
    
    echo "Load crab environment, grid environment should be loaded manually in advance if necessary"
    source /cvmfs/cms.cern.ch/crab3/crab.sh

    echo "Change number of events in crab config to"
    echo $NUMBEREVENTS
    echo " and copy crabconfig.py to workdir"
    sed -e "s/#NUMBEREVENTS#/${NUMBEREVENTS}/g" $STARTDIR/crabconfig_draft.py > ./crabconfig_eventsInserted.py
    sed -e "s/#REQUESTDATE#/`date  +'%Y%m%d%H%m%s'`/g" ./crabconfig_eventsInserted.py > ./crabconfig_dateInserted.py
    sed -e "s/#WHOAMI#/`whoami`/g" ./crabconfig_dateInserted.py > ./crabconfig_UserInserted.py

    export BASENAMEREPLACE=$(basename ${GRIDPACKLOC%.*})
    sed -e "s/#BASENAME#/${BASENAMEREPLACE}/g" ./crabconfig_UserInserted.py > ./crabconfig.py

        echo "Scram b and start of LHEGEN production"
        scram b -j 4

    echo "Submit crab jobs"
    crab submit crabconfig.py

    echo "Finished with crab submission, check job status manually"
else
    echo "Will do local production using cmsRun"

    echo "Copy gridpack for production to workdir"
    cp $GRIDPACKLOC gridpack.tgz

    echo "Add gridpack location to python config and copy cmssw python config to workdir"
    export GRIDPACKWORKDIR=`pwd`
    sed -e "s~#GRIDPACKLOCATION#~${GRIDPACKWORKDIR}/gridpack.tgz~g" ./pythonLHEGEN_cfg_eventsInserted.py > ./pythonLHEGEN_cfg.py

    echo "Scram b and start of LHEGEN production"
    scram b -j 4

    cmsRun pythonLHEGEN_cfg.py

    echo "Finished local production using cmsRun"
fi
