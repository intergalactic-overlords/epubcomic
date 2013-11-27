require 'fileutils'
require 'zlib'
require 'erb'

class App
  @title = 'test-title'
  @language = 'en'
  @vp_width = '100%'
  @vp_height = '100%'
  
  
  
  # create (hidden) temporary folder
  tmp_dir = 'tmp'
  unless File.exists?(tmp_dir) && File.directory?(tmp_dir)
    FileUtils.mkdir tmp_dir
    FileUtils.mkdir tmp_dir + '/original'
    FileUtils.mkdir tmp_dir + '/working'
    FileUtils.mkdir tmp_dir + '/new'
    FileUtils.mkdir tmp_dir + '/new/META-INF'
    FileUtils.mkdir tmp_dir + '/new/OPS'
    FileUtils.mkdir tmp_dir + '/new/OPS/css'
    FileUtils.mkdir tmp_dir + '/new/OPS/images'
    FileUtils.mkdir tmp_dir + '/new/OPS/xhtml'
  else
    print "tmp dir (#{tmp_dir}) already there?\n"
  end
  
  # check files in directory/search for cbr or cbz
  Dir.foreach 'comics' do |this_file|
    # some variables
    language = 'en'
    vp_width = 600
    vp_height = 800
    
    
    if File.extname(this_file) === '.cbz'
      # copy file to tmp
      original_file = './comics/' + this_file
      working_file = './' + tmp_dir + '/original/' + this_file
      FileUtils.cp original_file, working_file 
      
      # unzip on mac - http://sketchucation.com/forums/viewtopic.php?f=180&t=32390
      status = system "unzip -o \"#{working_file}\" -d \"#{tmp_dir}" + "/working" + "\""
      
      # move images to 'new' folder
      # list images + determine correct order of images
      images = Array.new
      Dir.foreach tmp_dir + '/working' do |that_file|
        file_types = ['.png', '.jpg', '.jpeg']
        if file_types.include? File.extname(that_file)
          source = tmp_dir + '/working/' + that_file
          destination = tmp_dir + '/new/OPS/images/' + that_file
          FileUtils.mv source, destination
          images.push({:image_name => that_file, :image_alt => ''})
        end
      end
      
      # copy standard files to 'new' folder
      FileUtils.cp 'templates/mimetype', tmp_dir + '/new/mimetype'
            
      # create custom files and add to 'new' folder
      
      # xhtml
      images.each do |image|
        template_xhtml = File.open('./templates/OPS/xhtml/page.xhtml.erb', 'r').read
        renderer = ERB.new(template_xhtml)
        filename = image[:image_name].chomp "jpg"
        filename = tmp_dir + '/new/OPS/xhtml/' + filename + "xhtml"
        File.open(filename, 'w+') { |file| file.write(renderer.result(binding)) }
        #puts renderer.result(binding)
      end
      
      # css
      # toc
      
      # zip and rename epub
      
      # move epub to new folder
      
      # clean up working files
        
    elsif File.extname(this_file) === '.cbr'
      print 'this is a cbr file'
    end
  end

  
  
  
  # compare size of images
  
  # check if some images are landscape -> they take up 2 pages
  
  # create new book
  
  # place images in epub (one new page per original page)
  
  # check for metadata
  
  # add metadata to new book
  
  # create epub?
  
  # remove (hidden) temporary folder
  # FileUtils.rm_rf tmp_dir
  
end