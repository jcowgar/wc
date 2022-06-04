#tag Class
Protected Class WordCounterByMemoryBlockBranchless
Inherits WordCounter
	#tag Event
		Sub Count(source As Readable)
		  #if not DebugBuild
		    #pragma BackgroundTasks false
		    #pragma BoundsChecking false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		  #endif
		  
		  const kBlock as integer = 16 * 1024
		  
		  Init
		  
		  var linefeedPtr as ptr = LinefeedMB
		  var whitespacePtr as ptr = WhitespaceMB
		  
		  var mb as new MemoryBlock( kBlock )
		  var p as ptr = mb
		  
		  var inWhitespace as integer = 1
		  
		  while not source.EndOfFile
		    
		    var block as string = source.Read( kBlock )
		    
		    Bytes = Bytes + block.Bytes
		    
		    mb.StringValue( 0, block.Bytes ) = block
		    
		    var lastByteIndex as integer = block.Bytes - 1
		    
		    for byteIndex as integer = 0 to lastByteIndex
		      
		      var thisByte as integer = p.Byte( byteIndex )
		      
		      var isLinefeed as integer = whitespacePtr.Byte( thisByte )
		      var isWhitespace as integer = whitespacePtr.Byte( thisByte )
		      var isWord as integer = 1 - isWhitespace
		      
		      Lines = Lines + isLinefeed
		      Words = Words + ( inWhitespace * isWord )
		      inWhitespace = isWhitespace
		      
		    next
		    
		  wend
		  
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Shared Sub Init()
		  if LinefeedMB isa object then
		    //
		    // Already inited
		    //
		    return
		  end if
		  
		  LinefeedMB = new MemoryBlock( 256 )
		  LinefeedMB.Byte( &hA ) = 1
		  
		  WhitespaceMB = new MemoryBlock( 256 )
		  var whitespaces() as UInt64 = array( &h9, &hA, &hB, &hC, &hD, &h20, &h85, &hA0 )
		  for each byteIndex as integer in whitespaces
		    WhitespaceMB.Byte( byteIndex ) = 1
		  next
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Shared LinefeedMB As MemoryBlock
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared WhitespaceMB As MemoryBlock
	#tag EndProperty


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
		#tag ViewProperty
			Name="Bytes"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Lines"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Words"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ElapsedSeconds"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
