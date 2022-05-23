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
		  
		  var buffer as new MemoryBlock( kBufferSize )
		  var p as ptr = buffer
		  
		  var inWord as boolean
		  
		  var byteCount as integer
		  var charCount as integer 
		  var wordCount as integer
		  var lineCount as integer
		  
		  while not reader.EndOfFile
		    var data as string = reader.Read( kBufferSize )
		    if data = "" then
		      exit
		    end if
		    
		    buffer.StringValue( 0, data.Bytes ) = data
		    
		    byteCount = byteCount + data.Bytes
		    var lastIndex as integer = data.Bytes - 1
		    
		    for byteIndex as integer = 0 to lastIndex
		      var code as integer = p.Byte( byteIndex )
		      
		      if code < &b10000000 or code > &b10111111 then
		        charCount = charCount + 1
		      end if
		      
		      select case code
		      case &h0A
		        inWord = false
		        lineCount = lineCount + 1
		        
		      case is <= 32, &hA0, &h85
		        inWord = false
		        
		      case else
		        if not inWord then
		          wordCount = wordCount + 1
		          inWord = true
		        end if
		        
		      end select
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


	#tag Constant, Name = kBufferSize, Type = Double, Dynamic = False, Default = \"32768", Scope = Protected
	#tag EndConstant


End Module
#tag EndModule
