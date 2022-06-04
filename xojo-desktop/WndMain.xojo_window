#tag DesktopWindow
Begin DesktopWindow WndMain
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   False
   HasMaximizeButton=   True
   HasMinimizeButton=   True
   Height          =   400
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   2049357823
   MenuBarVisible  =   False
   MinimumHeight   =   64
   MinimumWidth    =   64
   Resizeable      =   True
   Title           =   "WordCount"
   Type            =   0
   Visible         =   True
   Width           =   600
   Begin DesktopPopupMenu PUCounters
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      InitialValue    =   ""
      Italic          =   False
      Left            =   53
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   2
      SelectedRowIndex=   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   20
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   265
   End
   Begin DesktopButton BtnRun
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "Button"
      Default         =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   452
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      MacButtonStyle  =   0
      Scope           =   2
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   20
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   80
   End
   Begin DesktopTextArea FldResults
      AllowAutoDeactivate=   True
      AllowFocusRing  =   True
      AllowSpellChecking=   True
      AllowStyledText =   False
      AllowTabs       =   False
      BackgroundColor =   &cFFFFFF
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Format          =   ""
      HasBorder       =   True
      HasHorizontalScrollbar=   False
      HasVerticalScrollbar=   True
      Height          =   314
      HideSelection   =   True
      Index           =   -2147483648
      Italic          =   False
      Left            =   20
      LineHeight      =   0.0
      LineSpacing     =   1.0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      MaximumCharactersAllowed=   0
      Multiline       =   True
      ReadOnly        =   False
      Scope           =   2
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c000000
      Tooltip         =   ""
      Top             =   66
      Transparent     =   False
      Underline       =   False
      UnicodeMode     =   1
      ValidationMask  =   ""
      Visible         =   True
      Width           =   560
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  App.AllowAutoQuit = true
		  
		  PUCounters.AddRow new DesktopMenuItem( "By Byte", new WordCounterByByte )
		  PUCounters.AddRow new DesktopMenuItem( "By Blocks", new WordCounterByBlocks )
		  PUCounters.AddRow new DesktopMenuItem( "By MemoryBlock", new WordCounterByMemoryBlock )
		  PUCounters.AddRow new DesktopMenuItem( "By MemoryBlock Branchless", new WordCounterByMemoryBlockBranchless )
		  
		  PUCounters.SelectedRowIndex = 0
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function GetBinaryStream() As BinaryStream
		  var filename as string
		  
		  if DebugBuild then
		    filename = "mobydick.txt"
		  else
		    filename = "md-100.txt"
		  end if
		  
		  var f as FolderItem = SpecialFolder.Resource( filename )
		  var bs as BinaryStream = BinaryStream.Open( f )
		  return bs
		  
		End Function
	#tag EndMethod


#tag EndWindowCode

#tag Events BtnRun
	#tag Event
		Sub Pressed()
		  var bs as BinaryStream = GetBinaryStream
		  
		  var wc as WordCounter = PUCounters.RowTagAt( PUCounters.SelectedRowIndex )
		  wc.Count bs
		  
		  FldResults.AddText _
		  PUCounters.SelectedRowValue + ": " +  _
		  wc.Lines.ToString + " " +  _
		  wc.Words.ToString + " " +  _
		  wc.Bytes.ToString + " " +  _
		  wc.ElapsedSeconds.ToString( "#,##0.0###" ) + EndOfLine + EndOfLine
		  
		End Sub
	#tag EndEvent
#tag EndEvents
