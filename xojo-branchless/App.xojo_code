#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  var files() as FolderItem
		  var paths() as string
		  
		  var options as OptionParser = ParseArgs( args )
		  
		  if options is nil then
		    return 1
		  end if
		  
		  if options.HelpRequested then
		    options.ShowHelp
		    return 0
		  end if
		  
		  for each path as string in options.Extra
		    paths.Add path
		    
		    var f as FolderItem = OptionParser.GetRelativeFolderItem( path )
		    files.Add f
		  next
		  
		  if paths.Count = 0 then
		    paths.Add ""
		    files.Add nil
		  end if
		  
		  for i as integer = 0 to paths.LastIndex
		    var path as string = paths( i )
		    var file as FolderItem = files( i )
		    
		    var stats as WordCounter.Stats
		    
		    if file isa object and IsOnlyBytes then
		      //
		      // We can short circuit this
		      //
		      stats = new WordCounter.Stats
		      stats.Bytes = file.Length
		      
		      PrintStats stats, path
		      continue
		    end if
		    
		    var reader as Readable
		    if file is nil then
		      reader = stdin
		    else
		      reader = BinaryStream.Open( file, false )
		    end if
		    
		    if IsOnlyLines then
		      stats = WordCounter.CountLines( reader )
		    else
		      stats = WordCounter.Count( reader )
		    end if
		    
		    PrintStats stats, path
		  next
		  
		End Function
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function PadTo(num As Integer, padding As Integer) As String
		  static spacing as string = "        "
		  
		  var s as string = num.ToString
		  
		  var required as integer = padding - s.Length
		  
		  if required <= 0 then
		    return s
		  end if
		  
		  while spacing.Bytes < required
		    spacing = spacing + spacing
		  wend
		  
		  s = spacing.Left( required ) + s
		  return s
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseArgs(args() As String) As OptionParser
		  var countBytesOption as new Option( "c", kOptionBytes, "Count bytes", Option.OptionType.Boolean )
		  var countCharsOption as new Option( "m", kOptionCharacters, "Count characters", Option.OptionType.Boolean )
		  var countWordsOption as new Option( "w", kOptionWords, "Count words", Option.OptionType.Boolean )
		  var countLinesOption as new Option( "l", kOptionLines, "Count lines", Option.OptionType.Boolean )
		  
		  var parser as new OptionParser
		  
		  parser.AppName = "wc"
		  parser.AppDescription = "count stuff"
		  
		  parser.AddOption countBytesOption
		  parser.AddOption countCharsOption
		  parser.AddOption countWordsOption
		  parser.AddOption countLinesOption
		  
		  parser.Parse args
		  
		  if countBytesOption.WasSet or countCharsOption.WasSet or countWordsOption.WasSet or countLinesOption.WasSet then
		    CountBytes = countBytesOption.Value.BooleanValue
		    CountCharacters = countCharsOption.Value.BooleanValue
		    CountWords = countWordsOption.Value.BooleanValue
		    CountLines = countLinesOption.Value.BooleanValue
		  end if
		  
		  if CountBytes or CountCharacters or CountWords or CountLines then
		    return parser
		  else
		    parser.ShowHelp
		    return nil
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PrintStats(stats As WordCounter.Stats, path As String)
		  const kPadding as integer = 7
		  
		  var out() as string
		  
		  if CountLines then
		    out.Add PadTo( stats.Lines, kPadding )
		  end if
		  
		  if CountWords then
		    out.Add PadTo( stats.Words, kPadding )
		  end if
		  
		  if CountCharacters then
		    out.Add PadTo( stats.Characters, kPadding )
		  end if
		  
		  if CountBytes then
		    out.Add PadTo( stats.Bytes, kPadding )
		  end if
		  
		  if path <> "" then
		    out.Add path
		  end if
		  
		  print String.FromArray( out, " " )
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private CountBytes As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CountCharacters As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CountLines As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CountWords As Boolean = True
	#tag EndProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  return CountBytes and not (CountCharacters or CountWords or CountLines )
			  
			End Get
		#tag EndGetter
		Private IsOnlyBytes As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  return CountLines and not ( CountWords or CountCharacters or CountBytes )
			End Get
		#tag EndGetter
		Private IsOnlyLines As Boolean
	#tag EndComputedProperty


	#tag Constant, Name = kOptionBytes, Type = String, Dynamic = False, Default = \"bytes", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOptionCharacters, Type = String, Dynamic = False, Default = \"characters", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOptionLines, Type = String, Dynamic = False, Default = \"lines", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOptionWords, Type = String, Dynamic = False, Default = \"words", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
