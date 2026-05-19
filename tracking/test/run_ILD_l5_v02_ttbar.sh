#!/bin/bash
#
#==============================================================
# Running shell script in parallel over multiple cores
#==============================================================

ILDMODELRECO=ILD_l5_o1_v02
ILDMODELSIM=ILD_l5_v02
ILCSOFTVER=v01-19-06

. /afs/desy.de/project/ilcsoft/sw/x86_64_gcc49_sl6/${ILCSOFTVER}/init_ilcsoft.sh

INFILE=/nfs/dust/ilc/group/ild/dbd-data/500/6f/E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05.stdhep

#==================================================
#SIMULATION
NSkip=0
for i in {0..9}; do
	echo "NSkip ${NSkip}"

	ddsim \
		--inputFiles $INFILE \
		--outputFile ${ILDMODELSIM}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05_${i}_SIM.slcio \
		--compactFile $lcgeo_DIR/ILD/compact/${ILDMODELSIM}/${ILDMODELSIM}.xml \
		--steeringFile ddsim_steer.py \
		--numberOfEvents 100 \
		--skipNEvents ${NSkip} &

	NSkip=$(expr $NSkip + 100)

done
wait

mv ${ILDMODELSIM}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05_*_SIM.slcio Results/SimFiles

#=================================================
# RECONSTRUCTION
for i in {0..9}; do

	Marlin MarlinStdReco.xml \
		--constant.DetectorModel=${ILDMODELRECO} \
		--global.LCIOInputFiles=Results/SimFiles/${ILDMODELSIM}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05_${i}_SIM.slcio \
		--constant.RunBeamCalReco=false \
		--constant.lcgeo_DIR=$lcgeo_DIR \
		--constant.OutputBaseName=${ILDMODELRECO}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05_${i} \
		--MyRecoMCTruthLinker.UsingParticleGun=false \
		>RECO_${ILDMODELRECO}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05_${i}.out &

done
wait

# move all to folder RecoFiles

mv ${ILDMODELRECO}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05_*_REC.slcio Results/RecoFiles

# cleanup
rm ${ILDMODELRECO}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05_*_DST.slcio
rm ${ILDMODELRECO}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05_*_AIDA.root
rm ${ILDMODELRECO}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05_*_PfoAnalysis.root

#=================================================
# diagnostics

Marlin Diagnostics_${ILDMODELSIM}_ttbar.xml \
	--constant.lcgeo_DIR=$lcgeo_DIR \
	--constant.ILCSoftVersion=${ILCSOFTVER} \
	--MyAIDAProcessor.FileName=analysis_${ILDMODELRECO}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05 \
	--MyDiagnostics.PhysSampleOn=true \
	>DIAG_${ILDMODELRECO}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05.out

# move all to folder Analysis

cp analysis_${ILDMODELRECO}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05.root ../Results/Analysis/analysis_${ILDMODELRECO}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05.root
mv analysis_${ILDMODELRECO}_${ILCSOFTVER}_E0500-TDR_ws.Pyycyyc.Gwhizard-1.95.eR.pL.I36919.05.root ../Results/Analysis

# move log files to folder logFiles

#mv *.out logFiles
#mv *.err logFiles
#mv *.log logFiles

#==================================================
# generate monitor plots

cd ../macros
root -b -q EfficiencyL5.C

OUTPUTPATH=~/www/ILDPerformance_${ILCSOFTVER}
mkdir -p ${OUTPUTPATH}

cp trkEff_pt_ttbar_${ILDMODELRECO}.png ${OUTPUTPATH}/trkEff_pt_ttbar_${ILDMODELRECO}_${ILCSOFTVER}.png
cp trkEff_theta_ttbar_${ILDMODELRECO}.png ${OUTPUTPATH}/trkEff_theta_ttbar_${ILDMODELRECO}_${ILCSOFTVER}.png
