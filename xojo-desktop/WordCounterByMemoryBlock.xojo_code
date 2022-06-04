#tag Class
Protected Class WordCounterByMemoryBlock
Inherits WordCounter
	#tag Event
		Sub Count(source As Readable)
		  #if not DebugBuild
		    #pragma BackgroundTasks false
		    #pragma BoundsChecking false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		  #endif
		  
		  const kLinefeed as integer = &hA
		  
		  const kBlock as integer = 16 * 1024
		  
		  var mb as new MemoryBlock( kBlock )
		  var p as ptr = mb
		  
		  var inWhitespace as boolean = true
		  
		  while not source.EndOfFile
		    
		    var block as string = source.Read( kBlock )
		    
		    Bytes = Bytes + block.Bytes
		    
		    mb.StringValue( 0, block.Bytes ) = block
		    
		    var lastByteIndex as integer = block.Bytes - 1
		    
		    for byteIndex as integer = 0 to lastByteIndex
		      
		      var thisByte as integer = p.Byte( byteIndex )
		      
		      var isWhitespace as boolean = _
		      ( thisByte >= &h9 and thisByte <= &hD ) or _
		      thisByte = &h20 or _
		      thisByte = &h85 or _
		      thisByte = &hA0
		      
		      if isWhitespace then
		        if thisByte = kLinefeed then
		          Lines = Lines + 1
		        end if
		        
		        inWhitespace = true
		        
		      elseif inWhitespace then
		        //
		        // We are starting a new word
		        //
		        Words = Words + 1
		        inWhitespace = false
		        
		      end if
		      
		    next
		    
		  wend
		  
		  
		End Sub
	#tag EndEvent


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
