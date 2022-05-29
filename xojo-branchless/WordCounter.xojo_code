#tag Module
Protected Module WordCounter
	#tag Method, Flags = &h1
		Protected Function Count(reader As Readable) As WordCounter.Stats
		  #if not DebugBuild
		    #pragma BackgroundTasks false
		    #pragma BoundsChecking false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		  #endif
		  
		  Init
		  
		  var bufferSize as integer = kBufferSize
		  
		  var buffer as new MemoryBlock( bufferSize )
		  var pBuffer as ptr = buffer
		  
		  var pWhitespace as ptr = WhitespaceMB
		  var pEol as ptr = EolMB
		  
		  var wasInWhitespace as integer
		  
		  var byteCount as integer
		  var charCount as integer 
		  var wordCount as integer
		  var lineCount as integer
		  
		  
		  while not reader.EndOfFile
		    var data as string = reader.Read( bufferSize )
		    if data = "" then
		      exit
		    end if
		    
		    buffer.StringValue( 0, data.Bytes ) = data
		    
		    byteCount = byteCount + data.Bytes
		    var lastIndex as integer = data.Bytes - 1
		    
		    for byteIndex as integer = 0 to lastIndex
		      var code as integer = pBuffer.Byte( byteIndex )
		      var inWhitespace as integer = pWhitespace.Byte( code )
		      var inWord as integer = 1 - inWhitespace
		      
		      lineCount = lineCount + pEol.Byte( code )
		      wordCount = wordCount + ( wasInWhitespace * inWord )
		      wasInWhitespace = inWhitespace
		    next
		  wend
		  
		  var stats as new WordCounter.Stats
		  stats.Bytes = byteCount
		  stats.Characters = charCount
		  stats.Words = wordCount
		  stats.Lines = lineCount
		  
		  return stats
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CountLines(reader As Readable) As WordCounter.Stats
		  #if not DebugBuild
		    #pragma BackgroundTasks false
		    #pragma BoundsChecking false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		  #endif
		  
		  var buffer as new MemoryBlock( kBufferSize )
		  var p as ptr = buffer
		  
		  var count as integer 
		  
		  while not reader.EndOfFile
		    var data as string = reader.Read( kBufferSize )
		    if data = "" then
		      exit
		    end if
		    
		    buffer.StringValue( 0, data.Bytes ) = data
		    
		    var lastIndex as integer = data.Bytes - 1
		    for byteIndex as integer = 0 to lastIndex
		      if p.Byte( byteIndex ) = &h0A then
		        count = count + 1
		      end if
		    next
		  wend
		  
		  var stats as new WordCounter.Stats
		  stats.Lines = count
		  return stats
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Init()
		  if WasInited then
		    return
		  end if
		  
		  WhitespaceMB = new MemoryBlock( 256 )
		  
		  for i as integer = 9 to 13
		    WhitespaceMB.Byte( i ) = 1
		  next
		  
		  WhitespaceMB.Byte( 32 ) = 1
		  WhitespaceMB.Byte( &h85 ) = 1
		  WhitespaceMB.Byte( &hA0 ) = 1
		  
		  EolMB = new MemoryBlock( 256 )
		  EolMB.Byte( 10 ) = 1
		  
		  WasInited = true
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private EolMB As MemoryBlock
	#tag EndProperty

	#tag Property, Flags = &h21
		Private WasInited As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private WhitespaceMB As MemoryBlock
	#tag EndProperty


	#tag Constant, Name = kBufferSize, Type = Double, Dynamic = False, Default = \"16384", Scope = Protected
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
