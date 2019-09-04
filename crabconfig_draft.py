from WMCore.Configuration import Configuration
from CRABClient.UserUtilities import config, getUsernameFromSiteDB
config = Configuration()

config.section_("General")
config.General.requestName = "privateMCProduction#REQUESTDATE##WHOAMI#"
config.General.workArea = 'crab_privateMCProduction'
config.General.transferLogs = False

config.section_("JobType")
config.JobType.pluginName = 'PrivateMC'
config.JobType.psetName = 'pythonLHEGEN_cfg.py'
config.JobType.inputFiles = ['Z_ee_NNPDF31_13TeV_M_20.tgz']
config.JobType.disableAutomaticOutputCollection = False

config.section_("Data")
config.Data.outputPrimaryDataset = 'privateMCProductionLHEGENSIM'
config.Data.splitting = 'EventBased'
config.Data.unitsPerJob = 2000
config.Data.totalUnits = #NUMBEREVENTS#
config.Data.publication = False
config.Data.outputDatasetTag = 'eventLHEGEN-#BASENAME#-#REQUESTDATE#'
config.Data.outLFNDirBase = '/store/user/%s/' % (getUsernameFromSiteDB())

config.section_("Site")
config.Site.storageSite = 'T2_KR_KNU'
#config.Site.whitelist = ['T2_*']

config.section_("User")
