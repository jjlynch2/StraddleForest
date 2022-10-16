####################################################
###This contains helper functions for development###
####################################################
#save_object_json(@Name(L1_Options), L1_Options)
#read_object_json(filename = "all") #import all .json files from working dir
#read_object_json(filename = "L1_Options.json")

##macro to print name of variable/object as string
macro Name(arg)
   string(arg)
end

##reads json3 object from pwd() back into object
#filename = "all" indicates all files with a .json extension in the pwd()
function read_object_json(filename)
   if filename == "all"
      filename = []
      files = readdir()
      for f in files
         if f[end-3:end] == "json"
            @info "Importing $f..."
            push!(filename, f)
         end
      end
   end
   imported = []
   for file in filename
      file_temp = open(f->JSON3.read(f), file)
      push!(imported, file_temp)
   end
   return imported
end

##Saves object as json using json3
function save_object_json(filename, object)
    JSON3.write("$filename.json", object)
end
