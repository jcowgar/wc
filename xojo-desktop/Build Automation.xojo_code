#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin SignProjectStep Sign
				  DeveloperID=
				End
				Begin CopyFilesBuildStep CopyMDFile
					AppliesTo = 0
					Architecture = 0
					Target = 0
					Destination = 1
					Subdirectory = 
					FolderItem = Li4vLi4vdGVzdGRhdGEvbWQtMTAwMC50eHQ=
					FolderItem = Li4vLi4vdGVzdGRhdGEvbWQtMTAudHh0
					FolderItem = Li4vLi4vdGVzdGRhdGEvbWQtMTAwLnR4dA==
					FolderItem = Li4vLi4vdGVzdGRhdGEvbW9ieWRpY2sudHh0
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
			End
#tag EndBuildAutomation
