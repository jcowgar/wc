#tag Class
Protected Class WordCounter
	#tag Method, Flags = &h0
		Sub Count(source As Readable)
		  Reset
		  
		  var start as double = System.Microseconds
		  RaiseEvent Count( source )
		  ElapsedSeconds = ( System.Microseconds - start ) / 1000000.0
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reset()
		  Lines = 0
		  Words = 0
		  Bytes = 0
		  
		  ElapsedSeconds = 0
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Count(source As Readable)
	#tag EndHook


	#tag Property, Flags = &h0
		Bytes As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ElapsedSeconds As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		Lines As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Words As Integer
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
